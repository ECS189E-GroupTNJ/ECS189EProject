//
//  SpotifyUserModel.swift
//  Project
//
//  Created by user147183 on 11/21/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import Foundation

class Storage {
    static var currentPlaylistID: String? {
        get {
            return UserDefaults.standard.string(forKey: "currentPlaylistID")
        }
        
        set(currPlaylistIndex) {
            UserDefaults.standard.set(currPlaylistIndex, forKey: "currentPlaylistID")
            print("Current playlist ID was saved as \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var userID: String {
        get {
            return UserDefaults.standard.string(forKey: "userID") ?? ""
        }
        
        set(currentPlaylistID) {
            UserDefaults.standard.set(currentPlaylistID, forKey: "userID")
            print("User ID was saved as \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var displayName: String {
        get {
            return UserDefaults.standard.string(forKey: "displayName") ?? ""
        }
        
        set(displayName) {
            UserDefaults.standard.set(displayName, forKey: "displayName")
            print("Display name was saved as \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var playlistIDList: [String] {
        get {
            UserDefaults.standard.register(defaults: ["playlistIDList" : []])
            return UserDefaults.standard.array(forKey: "playlistIDList") as? [String] ?? []
        }
        
        set(playlistIDList) {
            UserDefaults.standard.set(playlistIDList, forKey: "playlistIDList")
            print("Current index number was saved")
        }
    }
    
    static var sendNotification: Bool {
        get {
            UserDefaults.standard.register(defaults: ["sendNotification" : false])
            return UserDefaults.standard.bool(forKey: "sendNotification")
        }
        set(sendNotification) {
            UserDefaults.standard.set(sendNotification, forKey: "sendNotification")
            print("Send notification setting was saved as \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var receiveNotification: Bool {
        get {
            UserDefaults.standard.register(defaults: ["receiveNotification" : false])
            return UserDefaults.standard.bool(forKey: "receiveNotification")
        }
        set(sendNotification) {
            UserDefaults.standard.set(sendNotification, forKey: "receiveNotification")
            print("Receive notification setting was saved as \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var useSmartSelection: Bool {
        get {
            UserDefaults.standard.register(defaults: ["useSmartSelection" : false])
            return UserDefaults.standard.bool(forKey: "useSmartSelection")
        }
        set(sendNotification) {
            UserDefaults.standard.set(sendNotification, forKey: "useSmartSelection")
            print("Send notification setting was saved as \(UserDefaults.standard.synchronize())")
        }
    }
}

class SpotifyUserModel {
    
    typealias ApiCompletion = ((_ response: [String: Any]?) -> Void)
    
    let baseURL = "https://api.spotify.com/v1"
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var playlistList: [(String, String, CIImage?)] = []
    var playlistStats: [String: (Double, Double, Double, Double, Double)] = [:]
    let statsCollectionBarrier = DispatchGroup()
    var currentPlaylistIndex: Int?
    let defaultPlaylistName = "ShareTunes Playlist"
    var currentTrackID: String?
    
    func configuration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        return config
    }
    
    struct TrackInfo {
        let albumImage: CIImage?
        let artistName: String
        let trackName: String
    }
    
    init(forTheFirstTime withValues: Bool) {
        if withValues {
            if let currentID = Storage.currentPlaylistID {
                self.currentPlaylistIndex = getPlaylistIndexOf(ID: currentID)
            }
        }
     }
    
    func getPlaylistIndexOf(ID: String) -> Int? {
        for (index, playlist) in Storage.playlistIDList.enumerated() {
            if ID == playlist {
                return index
            }
        }
        
        return nil
    }
    
    func SpotifyAPI(endpoint: String, param: [String: Any]?, completion: @escaping ApiCompletion) {
        // need to get proper access token, waiting for authentication process
        
        guard let url = URL(string: endpoint), let accessToken = delegate.appRemote.connectionParameters.accessToken else {
            return
        }
        
        let session = URLSession(configuration: configuration())
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let realParam = param {
            request.httpMethod = "POST"
            SpotifyPOST(session: session, request: request, param: realParam, completion: completion)
        }
        else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            SpotifyGET(session: session, request: request, completion: completion)
        }
    }
 
    
    func SpotifyGET(session: URLSession, request: URLRequest, completion: @escaping ApiCompletion) {
        session.dataTask(with: request) { (data, response, error) in
            self.handleHTTPResponse(withData: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    func SpotifyPOST(session: URLSession, request: URLRequest, param: [String: Any], completion: @escaping ApiCompletion) {
        guard let body = try? JSONSerialization.data(withJSONObject: param) else {
            DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
            return
        }
        
        session.uploadTask(with: request, from: body) { (data, response, error) in
            self.handleHTTPResponse(withData: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    func handleHTTPResponse(withData data: Data?, response: URLResponse?, error: Error?, completion: @escaping ApiCompletion) {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
                return
            }
        }
        guard let rawData = data else {
            DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
            return
        }
        let json = try? JSONSerialization.jsonObject(with: rawData)
        guard let responseData = json as? [String: Any] else {
            DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { completion(responseData) }
    }
    
    func imageGET(at endpoint: String, completion: @escaping ((_ data: CIImage?) -> Void)) {
        guard let url = URL(string: endpoint) else {
            DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
            return
        }
        
        if let data = try? Data(contentsOf: url) {
            DispatchQueue.global(qos: .userInitiated).async { completion(CIImage(data: data)) }
        }
        else {
            DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
        }
        
        /*
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        print(url.absoluteString)
        request.httpMethod = "GET"
        
        session.dataTask(with: url) { (data, response, error) in
            print("Try get image")
            if let httpResponse = response as? HTTPURLResponse {
                print("\(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                    DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
                    return
                }
            }
            if let realData = data {
                DispatchQueue.global(qos: .userInitiated).async { completion(CIImage(data: realData)) }
            }
            else {
                DispatchQueue.global(qos: .userInitiated).async { completion(nil) }
            }
        }
 */
    }
    
    func setSmartChoiceForCurrentTrack() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        guard let track = delegate.currentTrack?.uri else {
            print("Track not identified")
            return
        }
        
        let id = String(track.suffix(from: track.index(track.startIndex, offsetBy: 14)))
        
        setSmartChoice(for: id)
    }
    
    func setSmartChoice(for track: String) {
        let getAudioFeatureURL = "https://api.spotify.com/v1/audio-features/\(track)"
        SpotifyAPI(endpoint: getAudioFeatureURL, param: nil) { (response) in
            guard let features = response else {
                print("Couldn't get audio feature")
                return
            }
            
            if features.count == 0 {
                return
            }
            
            guard let danceability = features["danceability"] as? Double, let energy = features["energy"] as? Double, let loudness = features["loudness"] as? Double, let tempo = features["tempo"] as? Double, let valence = features["valence"] as? Double else {
                print("Error parsing audio feature")
                return
            }
            
            self.statsCollectionBarrier.wait()
            
            var min = 5.0
            
            for (index, playlist) in self.playlistList.enumerated() {
                if let stat = self.playlistStats[playlist.1] {
                    let dist = pow(stat.0 - danceability, 2) + pow(stat.1 - energy, 2) + pow(stat.2 - loudness / -60, 2) + pow(stat.3 - tempo / 200, 2) + pow(stat.4 - valence, 2)
                    if dist < min {
                        min = dist
                        //self.currentPlaylistIndex = index
                        //Storage.currentPlaylistID = playlist.1
                        print("Lowest so far: \(index)")
                    }
                }
            }
        }
    }
    
    func getCurrentTrackInfo() -> TrackInfo {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        guard let track = delegate.currentTrack?.uri else {
            print("Track not identified")
            return TrackInfo(albumImage: nil, artistName: "", trackName: "")
        }
        print("DO I NOT REACH HERE")
        let id = String(track.suffix(from: track.index(track.startIndex, offsetBy: 14)))
        
        return getTrackInfo(track: id)
    }
    
    func getTrackInfo(track: String) -> TrackInfo {
        let getTrackURL = "https://api.spotify.com/v1/tracks/\(track)"
        print(getTrackURL)
        var trackTitle = ""
        var artistNames = ""
        var cover: CIImage? = nil
        let getImageBarrier = DispatchGroup()
        getImageBarrier.enter()
        SpotifyAPI(endpoint: getTrackURL, param: nil) { (response) in
            guard let realResponse = response, let title = realResponse["name"] as? String else {
                print("Track not found")
                return
            }
            
            guard let albumImages = (realResponse["album"] as? [String: Any])?["images"] as? [[String: Any]] else {
                print("Album not found")
                return
            }
            
            guard let artists = (realResponse["artists"] as? [[String: Any]]) else {
                print("Artists not found")
                return
            }

            if albumImages.count > 0 {
                guard let imageURL = albumImages[0]["url"] as? String else {
                    print("Unexpected error from album image")
                    return
                }
                print(imageURL)
                
                self.imageGET(at: imageURL) { (data) in
                    if let image = data {
                        cover = image
                        print("wtf")
                    }
                    getImageBarrier.leave()
                }
            }
            trackTitle = title
            var names: [String] = []
            
            
            for artist in artists {
                guard let name = artist["name"] as? String else {
                    print("Unexpected error in artist name")
                    return
                }
                names.append(name)
            }
            
            artistNames = names.joined(separator: ", ")
            print("AHHHHH \(artistNames)")
            print("????? \(artistNames)")
        }
        
        getImageBarrier.wait()
        print(artistNames, trackTitle, "ASDASDAS")
        return TrackInfo(albumImage: cover, artistName: artistNames, trackName: trackTitle)
    }
    
    func addCurrentTrackToPlaylist(callback: @escaping () -> Void) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        // need current track information (requires Spotify authorization in advance)
        guard let track = delegate.currentTrack?.uri else {
            print("Track not identified")
            return
        }
        
        addTrackToPlaylist(track: track, callback: callback)
    }
    
    
    func addTrackToPlaylist(track: String, callback: @escaping () -> Void) {
        if Storage.useSmartSelection {
            setSmartChoiceForCurrentTrack()
        }
        
        if self.currentPlaylistIndex == nil && getPlaylistIndexOf(playlistName: defaultPlaylistName) == nil {
            getDefaultPlaylist()
        }
        
        guard let playlistIndex = self.currentPlaylistIndex else {
            print("Error with the index of the playlist");
            return
        }
        
        print("SAVE TO:",playlistIndex)
        
        let playlistID = Storage.playlistIDList[playlistIndex]
        if let currentID = Storage.currentPlaylistID, playlistID != currentID {
            self.currentPlaylistIndex = getPlaylistIndexOf(ID: currentID)
        }
        
        var postTrackURL = "\(baseURL)/playlists/\(playlistID)/tracks"
        
        SpotifyAPI(endpoint: postTrackURL, param: ["uris": [track]]) { (response) in
            if response == nil {
                print("Could not add track to playlist")
                self.getDefaultPlaylist()
                postTrackURL = "\(self.baseURL)/playlists/\(playlistID)/tracks"
                self.SpotifyAPI(endpoint: postTrackURL, param: ["uris": [track]]) { (response) in
                    if response == nil {
                        print("Track addition failed")
                    }
                    else {
                        print("Added to the default playlist")
                        self.currentTrackID = String(track.suffix(from: track.index(track.startIndex, offsetBy: 14)))
                        DispatchQueue.main.async{ callback() }
                    }
                }
            }
            else {
                print("Addition successful")
                self.currentTrackID = String(track.suffix(from: track.index(track.startIndex, offsetBy: 14)))
                DispatchQueue.main.async{ callback() }
            }
        }
    }
    
    func getDefaultPlaylist() {
        let defaultPlaylistBarrier = DispatchGroup()
        defaultPlaylistBarrier.enter()
        
        if let index = getPlaylistIndexOf(playlistName: defaultPlaylistName) {
            let defaultID = Storage.playlistIDList[index]
            let getPlaylistURL = "\(baseURL)/playlists/\(defaultID)"
            SpotifyAPI(endpoint: getPlaylistURL, param: nil) { (response) in
                if response == nil {
                    self.createPlaylist(withName: self.defaultPlaylistName, andLeave: defaultPlaylistBarrier)
                }
                else {
                    self.currentPlaylistIndex = index
                    Storage.currentPlaylistID = Storage.playlistIDList[index]
                    defaultPlaylistBarrier.leave()
                }
            }
        }
        else {
            self.createPlaylist(withName: self.defaultPlaylistName, andLeave: defaultPlaylistBarrier)
        }
        defaultPlaylistBarrier.wait()
    }
    
    func createPlaylist(withName name: String, andLeave barrier: DispatchGroup? = nil) {
        let postPlaylistURL = "\(self.baseURL)/me/playlists"
        self.SpotifyAPI(endpoint: postPlaylistURL, param: ["name": name, "public": false, "description": "Auto-created playlist for the app"]) { (response) in
            if let realResponse = response, let id = realResponse["id"] as? String {
                self.playlistList.insert((name, id, nil), at: 0)
                Storage.playlistIDList.insert(id, at: 0)
                self.currentPlaylistIndex = 0
                Storage.currentPlaylistID = Storage.playlistIDList[0]
            }
            if let barrier = barrier {
                barrier.leave()
            }
        }
    }
 
    
    func getPlaylistIndexOf(playlistName name: String) -> Int? {
        for (index, item) in playlistList.enumerated() {
            if item.0 == name {
                return index
            }
        }
        return nil
    }
    
    func updatePlaylists(completion: @escaping () -> Void) {
        let getPlaylistURL = "\(baseURL)/me/playlists?limit=50"
        let getPlaylistQueue = DispatchQueue(label: "get playlist queue")
        self.currentPlaylistIndex = nil
        playlistList = []
        var playlistIDList: [String] = []
        
        getPlaylistQueue.async {
            var next: String? = getPlaylistURL
            let nextBarrier = DispatchGroup()
            while next != nil {
                nextBarrier.enter()
                let imageBarrier = DispatchGroup()
                self.SpotifyAPI(endpoint: next!, param: nil) { (response) in
                    guard let realResponse = response else {
                        print("Error accesing server")
                        nextBarrier.leave()
                        return
                    }
                    
                    guard let items = realResponse["items"] as? [[String: Any]] else {
                        print("Get Playlists item error")
                        return
                    }
                    print(items.count)
                    for playlist in items {
                        var image: CIImage? = nil
                        
                        if let images = playlist["images"] as? [[String: Any]] {
                            if images.count > 0, let imageURL = images[0]["url"] as? String {
                                imageBarrier.enter()
                                self.imageGET(at: imageURL) { (data) in
                                    guard let realData = data else {
                                        print("Unable to retrieve album image")
                                        imageBarrier.leave()
                                        return
                                    }
                                    image = realData
                                    imageBarrier.leave()
                                }
                            }
                        }
                        
                        guard let name = playlist["name"] as? String, let id = playlist["id"] as? String else {
                            print("Playlist does not have name or id")
                            return
                        }
                        
                        if let currID = Storage.currentPlaylistID, currID == id {
                            self.currentPlaylistIndex = self.playlistList.count
                        }
                        
                        if playlist["collaborative"] as? Bool == false, (playlist["owner"] as? [String: Any])?["id"] as? String != Storage.userID {
                            continue
                        }
                        
                        imageBarrier.wait()
                        self.playlistList.append((name, id, image))
                        playlistIDList.append(id)
                        DispatchQueue.main.async { completion() }
                        
                        if Storage.useSmartSelection {
                            print("Start collecting stats")
                            self.computeStatsForPlaylist(playlist, withID: id)
                        }
                    }
                    
                    if let nextURL = realResponse["next"] as? String {
                        next = nextURL
                    }
                    else {
                        next = nil
                    }
                    
                    nextBarrier.leave()
                }
                nextBarrier.wait()
            }
            Storage.playlistIDList = playlistIDList
            print(Storage.playlistIDList.count)
        }
        
    }
    
    func computeStatsForPlaylist(_ playlist: [String: Any], withID id: String) {
        self.statsCollectionBarrier.enter()
        DispatchQueue.global(qos: .default).async {
            // start stats collection
            guard let getTracksURL = (playlist["tracks"] as? [String: Any])?["href"] as? String else {
                print("Could not get tracks for the playlist")
                self.statsCollectionBarrier.leave()
                return
            }
            
            self.SpotifyAPI(endpoint: getTracksURL, param: nil) { (response) in
                guard let realResponse = response?["items"] as? [[String: Any]] else {
                    print("Error getting tracks from the playlist")
                    self.statsCollectionBarrier.leave()
                    return
                }
                
                var tracks: [String] = []
                
                for track in realResponse {
                    if let trackID = (track["track"] as? [String: Any])?["id"] as? String {
                        tracks.append(trackID)
                    }
                }
                
                let getAudioFeaturesURL = "https://api.spotify.com/v1/audio-features?ids=\(tracks.joined(separator: ","))"
                
                self.SpotifyAPI(endpoint: getAudioFeaturesURL, param: nil) { (response) in
                    guard let features = response?["audio_features"] as? [[String: Any]] else {
                        print("Couldn't get audio features")
                        self.statsCollectionBarrier.leave()
                        return
                    }
                    print("Audio features received")
                    self.processAudioFeatures(features, forPlaylistID: id)
                }
            }
        }
    }
    
    func processAudioFeatures(_ features: [[String: Any]], forPlaylistID id: String) {
        var danceability = 0.0, energy = 0.0, loudness = 0.0, tempo = 0.0, valence = 0.0, count = 0.0
        
        for feature in features {
            if let d = feature["danceability"] as? Double, let e = feature["energy"] as? Double, let l = feature["loudness"] as? Double, let t = feature["tempo"] as? Double, let v = feature["valence"] as? Double {
                danceability += d
                energy += e
                loudness += l / -60.0
                tempo += t / 200
                valence += v
                count += 1
            }
        }
        self.playlistStats[id] = (danceability / count, energy / count, loudness / count, tempo / count, valence / count)
        print(self.playlistStats[id])
        self.statsCollectionBarrier.leave()
    }
 
}
