//
//  ViewController.swift
//  Project
//
//  Created by user147183 on 11/21/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var connectWithSpotifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        connectWithSpotifyButton.layer.cornerRadius = connectWithSpotifyButton.frame.height / 2
        connectWithSpotifyButton.setTitleColor(UIColor.white, for: .normal)
        connectWithSpotifyButton.backgroundColor = UIColor.green
        
        connectWithSpotifyButton.layer.shadowColor = UIColor.white.cgColor
        connectWithSpotifyButton.layer.shadowRadius = 50
        connectWithSpotifyButton.layer.shadowOpacity = 0.5
        connectWithSpotifyButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }

    @IBAction func connectToSpotify() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let scope: SPTScope = [.appRemoteControl, .playlistModifyPublic, .playlistModifyPrivate, .playlistReadPrivate, .userLibraryRead, .userLibraryModify, .userReadCurrentlyPlaying]
        delegate.sessionManager.initiateSession(with: scope, options: .default)
    }
}

