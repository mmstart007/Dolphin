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
        //imageViewUserAvatar.layer.cornerRadius = imageViewUserAvatar.frame.size.width / 2
        //imageViewUserAvatar.layer.masksToBounds = true
    }
    
    func configureAsUser(_ imageUrl: String) {
        let url : URL = URL(string: self.convertURL(imageUrl))!
        imageViewUserAvatar.backgroundColor = UIColor.white
        imageViewUserAvatar.sd_setImage(with: url, placeholderImage: UIImage(named: "UserPlaceholder"))
        imageViewUserAvatar.contentMode = .scaleAspectFill
        imageViewUserAvatar.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    func configureAsMoreUsers(_ count: Int) {
        
        imageViewUserAvatar.backgroundColor = UIColor.white
        imageViewUserAvatar.contentMode = .center
        
        let otherUsersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: imageViewUserAvatar.frame.size.width, height: imageViewUserAvatar.frame.size.width))
        otherUsersLabel.backgroundColor = UIColor.lightGray
        otherUsersLabel.textColor = UIColor.lightText
        //otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
        //otherUsersLabel.layer.masksToBounds = true
        otherUsersLabel.text = String(format: "+%li", arguments: [count])
        otherUsersLabel.textAlignment = .center
        otherUsersLabel.font = UIFont.systemFont(ofSize: 16)
        imageViewUserAvatar.addSubview(otherUsersLabel)
        imageViewUserAvatar.image = nil
    }

    func convertURL(_ urlString: String) -> String {
        if urlString.contains("http") {
            return urlString
        } else {
            return Constants.RESTAPIConfig.Developement.BaseUrl + urlString
        }
    }
    
}
