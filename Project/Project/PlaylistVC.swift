//
//  PlaylistVC.swift
//  Project
//
//  Created by Noshin Kamal on 11/26/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

class PlaylistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userModel: SpotifyUserModel = SpotifyUserModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel.playlistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (playlistTable.dequeueReusableCell(withIdentifier: "playlistCell") ?? PlaylistTableViewCell(style: .subtitle, reuseIdentifier: "playlistCell")) as! PlaylistTableViewCell
        
        if let selected = userModel.currentPlaylistIndex, selected == indexPath.row {
            cell.selectedButton.isSelected = true
        }
        else {
            cell.selectedButton.isSelected = false
        }
        cell.playlistName.text = userModel.playlistList[indexPath.row].0
        cell.playlistCover.image = userModel.playlistList[indexPath.row].2
        
        return cell
    }
    

    @IBOutlet weak var playlistTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTable.delegate = self
        playlistTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
