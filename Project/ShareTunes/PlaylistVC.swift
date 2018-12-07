//
//  PlaylistVC.swift
//  Project
//
//  Created by Noshin Kamal on 11/26/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

class PlaylistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userModel: SpotifyUserModel = SpotifyUserModel(forTheFirstTime: false)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel.playlistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (playlistTable.dequeueReusableCell(withIdentifier: "playlistCell") ?? PlaylistTableViewCell(style: .subtitle, reuseIdentifier: "playlistCell")) as! PlaylistTableViewCell
        let background = UIView()
        background.backgroundColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        cell.selectedBackgroundView = background
        if let selected = userModel.currentPlaylistIndex, selected == indexPath.row {
            cell.selectedButton.isSelected = true
        }
        else {
            cell.selectedButton.isSelected = false
        }
        cell.playlistName.text = userModel.playlistList[indexPath.row].0
        
        if let image = userModel.playlistList[indexPath.row].2 {
            cell.playlistCover.image = UIImage(ciImage: image)
        }
        else {
            cell.playlistCover.image = UIImage(named: "defaultCover")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prev = userModel.currentPlaylistIndex {
            let prevCell = tableView.cellForRow(at: IndexPath(row: prev, section: 0)) as! PlaylistTableViewCell
            prevCell.selectedButton.isSelected = false
        }
        let cell = tableView.cellForRow(at: indexPath) as! PlaylistTableViewCell
        tableView.deselectRow(at: indexPath, animated: true)
        cell.selectedButton.isSelected = true
        userModel.currentPlaylistIndex = indexPath.row
        Storage.currentPlaylistID = userModel.playlistList[indexPath.row].1
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBOutlet weak var playlistTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        playlistTable.delegate = self
        playlistTable.dataSource = self
        
        userModel.updatePlaylists {
            self.playlistTable.reloadData()
        }
        
        
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
