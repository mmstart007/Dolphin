//
//  PODPreviewTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODPreviewTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podNameLabel: UILabel!
    @IBOutlet weak var podLastPostDateLabel: UILabel!
    @IBOutlet weak var podUsersContainerView: UIView!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            let separation: CGFloat = 6.0
            frame.origin.x          += separation
            frame.origin.y          += separation
            frame.size.width        = frame.size.width - (separation * 2.0)
            frame.size.height       = frame.size.height - (separation * 2.0)
            super.frame             = frame
        }
    }
    
    func configureWithPOD(pod: POD) {
        podImageView.sd_setImageWithURL(NSURL(string: (pod.podImageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        self.layer.cornerRadius          = 5
        podImageView.layer.cornerRadius  = 5
        podImageView.layer.masksToBounds = true
        podNameLabel.text                = pod.podName
        podLastPostDateLabel.text        = pod.podLastPostDate?.timeAgo()
    }
    
    func addUserImages(pod: POD) {
        for (var i = 0; (i < pod.podUsers?.count && i < 5); i++) {
            if i == 0 && pod.podUsers?.count > 5 {
                // Add Label that shows number of remaining users in POD
                let x: CGFloat = podUsersContainerView.frame.size.width - podUsersContainerView.frame.size.width / 6 - (CGFloat(i) * (podUsersContainerView.frame.size.width / 6 + podUsersContainerView.frame.size.width / 24))
                let otherUsersLabel = UILabel(frame: CGRect(x: x, y: 0, width: podUsersContainerView.frame.size.width / 6, height: podUsersContainerView.frame.size.width / 6))
                otherUsersLabel.backgroundColor = UIColor.lightGrayColor()
                otherUsersLabel.textColor = UIColor.lightTextColor()
                otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
                otherUsersLabel.layer.masksToBounds = true
                otherUsersLabel.text = String(format: "+%li", arguments: [(pod.podUsers?.count)! - 4])
                otherUsersLabel.textAlignment = .Center
                otherUsersLabel.font = UIFont.systemFontOfSize(12)
                podUsersContainerView.addSubview(otherUsersLabel)
            } else {
                // Sow image of user in POD
                let x: CGFloat = podUsersContainerView.frame.size.width - podUsersContainerView.frame.size.width / 6 - (CGFloat(i) * (podUsersContainerView.frame.size.width / 6 + podUsersContainerView.frame.size.width / 24))
                let userAvatarImageView = UIImageView(frame: CGRect(x: x, y: 0, width: podUsersContainerView.frame.size.width / 6, height: podUsersContainerView.frame.size.width / 6))
                userAvatarImageView.sd_setImageWithURL(NSURL(string: (pod.podUsers![i].userImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
                userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2.0
                userAvatarImageView.layer.masksToBounds = true
                podUsersContainerView.addSubview(userAvatarImageView)
            }
        }
    }
    
}
