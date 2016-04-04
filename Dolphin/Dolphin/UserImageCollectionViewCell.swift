//
//  UserImageCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class UserImageCollectionViewCell : CustomFontCollectionViewCell  {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2
        userAvatarImageView.clipsToBounds = true
    }
    
    func configureAsAddUser() {
        userAvatarImageView.backgroundColor = UIColor.whiteColor()
        userAvatarImageView.image = UIImage(named: "PlusIconSmall")
        userAvatarImageView.contentMode = .Center
        userNameLabel.text = "Add"
    }
    
    func configureWithUser(user: User) {
        userAvatarImageView.backgroundColor = UIColor.whiteColor()
        userAvatarImageView.contentMode = .ScaleAspectFill
        if let userAvatarURL = user.userAvatarImageURL {
            userAvatarImageView.sd_setImageWithURL(NSURL(string: userAvatarURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            userAvatarImageView.image = UIImage(named: "UserPlaceholder")
        }
        userNameLabel.text = user.userName
    }
    
}
