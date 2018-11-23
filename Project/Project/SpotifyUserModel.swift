//
//  SpotifyUserModel.swift
//  Project
//
//  Created by user147183 on 11/21/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import Foundation

class SpotifyUserModel {
    
    typealias ApiCompletion = ((_ response: [String: Any]?) -> Void)
    
    let baseURL = "https://api.spotify.com/v1"
    var playlistList: [(String, String)] = []
    var currentPlaylistIndex: Int?
    let defaultPlaylistName = "default"
    
    func configuration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        return config
    }
    
    func SpotifyAPI(endpoint: String, param: [String: Any]?, completion: @escaping ApiCompletion) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
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
    
    func getDefaultPlaylist() {
        let defaultPlaylistBarrier = DispatchGroup()
        defaultPlaylistBarrier.enter()
        
        if let index = getPlaylistIndexOf(playlistName: defaultPlaylistName) {
            let defaultID = playlistList[index].1
            let getPlaylistURL = "\(baseURL)/playlists/\(defaultID)"
            SpotifyAPI(endpoint: getPlaylistURL, param: nil) { (response) in
                if response == nil {
                    self.createPlaylist(withName: self.defaultPlaylistName, andLeave: defaultPlaylistBarrier)
                }
                else {
                    self.currentPlaylistIndex = index
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
                self.playlistList.insert((name, id), at: 0)
                self.currentPlaylistIndex = 0
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
    
    func updatePlaylists() {
        let getPlaylistURL = "\(baseURL)/me/playlists?limit=50"
        let getPlaylistQueue = DispatchQueue(label: "get playlist queue")
        var updatedPlaylistList: [(String, String)] = []
        
        getPlaylistQueue.sync {
            var next: String? = getPlaylistURL
            let nextBarrier = DispatchGroup()
            while next != nil {
                nextBarrier.enter()
                self.SpotifyAPI(endpoint: next!, param: nil) { (response) in
                    guard let realResponse = response else {
                        print("Error accesing server")
                        return
                    }
                    
                    guard let items = realResponse["items"] as? [[String: Any]] else {
                        print("Get Playlists item error")
                        return
                    }
                    for playlist in items {
                        guard let name = playlist["name"] as? String, let id = playlist["id"] as? String else {
                            print("Playlist does not have name or id")
                            return
                        }
                        updatedPlaylistList.append((name, id))
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
        }
        self.playlistList = updatedPlaylistList
        
    }
    
    
}
