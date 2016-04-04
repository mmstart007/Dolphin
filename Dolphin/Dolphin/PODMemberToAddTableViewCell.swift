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
    @IBOutlet weak var actionImageView: UIImageView!
    
    func configureWithUser(user: User, isAdded: Bool) {
        if user.userAvatarImageURL == nil || user.userAvatarImageURL == "" {
            userImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            userImageView.sd_setImageWithURL(NSURL(string: user.userAvatarImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        userNameLabel.text = user.userName
        
        if isAdded {
            actionImageView.image = UIImage(named: "CloseOverlayIcon")
            backgroundColor = UIColor.whiteColor()
        } else {
            actionImageView.image = UIImage(named: "PlusIconSmall")
            backgroundColor = UIColor.lightGrayColor()
        }
    }
    
}
