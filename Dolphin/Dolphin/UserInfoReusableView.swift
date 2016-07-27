//
//  UserInfoReusableView.swift
//  Dolphin
//
//  Created by star on 7/27/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class UserInfoReusableView: UICollectionReusableView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2.0
    }
    
}
