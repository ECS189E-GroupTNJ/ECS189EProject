//
//  PopUpViewController.swift
//  Project
//
//  Created by Noshin Kamal on 12/3/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit
import MarqueeLabel

class PopUpViewController: UIViewController {

    var trackInfo: SpotifyUserModel.TrackInfo?
    var senderName: String = ""
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: MarqueeLabel!
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    
    @IBOutlet weak var albumCoverImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promptLabel.text = "\(senderName) added this song"
        print(trackInfo?.artistName)
        trackTitleLabel.text = trackInfo?.trackName ?? "Title not found"
        artistNameLabel.text = trackInfo?.artistName ?? "Artist name not found"
        albumCoverImage.image = trackInfo?.albumImage == nil ? UIImage(named: "defaultCover") : UIImage(ciImage: trackInfo!.albumImage!)
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
