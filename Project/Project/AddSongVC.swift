//
//  AddSongVC.swift
//  Project
//
//  Created by Noshin Kamal on 11/26/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

class AddSongVC: UIViewController {

    @IBOutlet weak var captureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.layer.cornerRadius = captureButton.frame.height / 2
        captureButton.setTitleColor(UIColor.white, for: .normal)
        captureButton.layer.shadowColor = UIColor.red.cgColor
        captureButton.layer.shadowRadius = 50
        captureButton.layer.shadowOpacity = 0.5
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

}
