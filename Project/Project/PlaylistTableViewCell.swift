//
//  PlaylistTableViewCell.swift
//  Project
//
//  Created by user147183 on 11/27/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedButton: RadioButton!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var playlistCover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
