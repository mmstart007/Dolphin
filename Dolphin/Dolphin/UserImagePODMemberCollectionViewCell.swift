//
//  UserImagePODMemberCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/16/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class UserImagePODMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewUserAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewUserAvatar.layer.cornerRadius = imageViewUserAvatar.frame.size.width / 2
        imageViewUserAvatar.layer.masksToBounds = true
    }
    
    func configureAsUser(imageUrl: String) {
        let url : NSURL = NSURL(string: imageUrl)!
        imageViewUserAvatar.backgroundColor = UIColor.whiteColor()
        imageViewUserAvatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "UserPlaceholder"))
        imageViewUserAvatar.contentMode = .ScaleAspectFit
        imageViewUserAvatar.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

    }
    
    func configureAsMoreUsers(count: Int) {
        
        imageViewUserAvatar.backgroundColor = UIColor.whiteColor()
        imageViewUserAvatar.contentMode = .Center
        
        let otherUsersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: imageViewUserAvatar.frame.size.width, height: imageViewUserAvatar.frame.size.width))
        otherUsersLabel.backgroundColor = UIColor.lightGrayColor()
        otherUsersLabel.textColor = UIColor.lightTextColor()
        otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
        otherUsersLabel.layer.masksToBounds = true
        otherUsersLabel.text = String(format: "+%li", arguments: [count])
        otherUsersLabel.textAlignment = .Center
        otherUsersLabel.font = UIFont.systemFontOfSize(16)
        imageViewUserAvatar.addSubview(otherUsersLabel)
        imageViewUserAvatar.image = nil
    }

}
