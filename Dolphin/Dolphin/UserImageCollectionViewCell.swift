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
        userAvatarImageView.backgroundColor = UIColor.white
        userAvatarImageView.image = UIImage(named: "PlusIconSmall")
        userAvatarImageView.contentMode = .center
        userNameLabel.text = "Add"
        deleteButton.isHidden = true
    }
    
    func configureWithUser(_ user: User) {
        self.selectedUser = user
        userAvatarImageView.backgroundColor = UIColor.white
        userAvatarImageView.contentMode = .scaleAspectFill
        if let userAvatarURL = user.userAvatarImageURL {
            userAvatarImageView.sd_setImage(with: URL(string: userAvatarURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            userAvatarImageView.image = UIImage(named: "UserPlaceholder")
        }
        userNameLabel.text = user.userName
        deleteButton.isHidden = false
    }
}
