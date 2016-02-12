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
    }
    
    func configureAsAddUser() {
        userAvatarImageView.backgroundColor = UIColor.whiteColor()
        userAvatarImageView.image = UIImage(named: "PlusIconSmall")
        userAvatarImageView.contentMode = .Center
        userNameLabel.text = "Add"
    }
    
}
