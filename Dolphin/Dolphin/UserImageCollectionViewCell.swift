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
    @IBOutlet weak var deleteButton: UIButton!
    var selectedUser: User!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width/2
        deleteButton.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2
        userAvatarImageView.clipsToBounds = true
    }
    
    func configureAsAddUser() {
        userAvatarImageView.backgroundColor = UIColor.whiteColor()
        userAvatarImageView.image = UIImage(named: "PlusIconSmall")
        userAvatarImageView.contentMode = .Center
        userNameLabel.text = "Add"
        deleteButton.hidden = true
    }
    
    func configureWithUser(user: User) {
        self.selectedUser = user
        userAvatarImageView.backgroundColor = UIColor.whiteColor()
        userAvatarImageView.contentMode = .ScaleAspectFill
        if let userAvatarURL = user.userAvatarImageURL {
            userAvatarImageView.sd_setImageWithURL(NSURL(string: userAvatarURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            userAvatarImageView.image = UIImage(named: "UserPlaceholder")
        }
        userNameLabel.text = user.userName
        deleteButton.hidden = false
    }
}
