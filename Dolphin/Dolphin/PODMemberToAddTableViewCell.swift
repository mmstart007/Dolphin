//
//  PODMemberToAddTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODMemberToAddTableViewCell : UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
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
            let addLabel = UILabel(frame: CGRect(x: -30, y: 0, width: 50, height: 21))
            addLabel.text = "Add"
            addLabel.textColor = UIColor.whiteColor()
            addLabel.font = addLabel.font.fontWithSize(12)
            addLabel.backgroundColor = UIColor.greenDolphinDealHeader()
            addLabel.textAlignment = .Center
            addLabel.layer.cornerRadius = 5
            addLabel.clipsToBounds = true
            actionImageView.addSubview(addLabel)
            actionImageView.image = nil
            backgroundColor = UIColor.lightGrayBackground()
        }
    }
    
}
