//
//  ViewController.swift
//  Project
//
//  Created by user147183 on 11/21/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit
import PopupDialog

class ConnectionVC: UIViewController {
    
    
    @IBOutlet weak var connectWithSpotifyButton: UIButton!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectWithSpotifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.connectWithSpotifyButton.titleLabel?.minimumScaleFactor = 0.5
        
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
        print("Button")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let scope: SPTScope = [.appRemoteControl, .playlistModifyPublic, .playlistModifyPrivate, .playlistReadPrivate, .userLibraryRead, .userLibraryModify, .userReadCurrentlyPlaying, .playlistReadCollaborative]
        delegate.sessionManager.initiateSession(with: scope, options: .clientOnly)
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.waitUntilConnected(attempt: 1)
        }
        
    }
    
    func waitUntilConnected(attempt: Int) {
        if attempt > 10 {
            self.popupWithMessage(title: "Connection Timeout", body: "ShareTunes was unable to connect to Spotify. Try again.")
        }
        else if self.delegate.appRemote.isConnected {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addSongVC")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
                self.waitUntilConnected(attempt: attempt + 1)
            }
        }
    }
    
    func popupWithMessage(title: String, body: String) {
        let popup = PopupDialog(title: title, message: body)
        popup.view.backgroundColor = UIColor.groupTableViewBackground
        
        let confirm = DefaultButton(title: "Confirm") {
            
        }
        confirm.backgroundColor = UIColor.groupTableViewBackground
        
        popup.addButton(confirm)
        
        self.present(popup, animated: true)
    }
    
}

