//
//  PODMemberToAddTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODMemberToAddTableViewCell : CustomFontTableViewCell {
 
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    func configureWithUser(user: User) {
        if user.userAvatarImageURL == nil || user.userAvatarImageURL == "" {
            userImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            userImageView.sd_setImageWithURL(NSURL(string: user.userAvatarImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        userNameLabel.text = user.userName
    }
    
}
