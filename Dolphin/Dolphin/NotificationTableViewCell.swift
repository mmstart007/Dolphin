//
//  NotificationTableViewCell.swift
//  Dolphin
//
//  Created by Joachim on 9/1/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(notification: Notification!) {
        
        if let userImageUrl = notification.sender?.userAvatarImageURL {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: (userImageUrl)), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            self.avatarImageView.image = UIImage(named: "UserPlaceholder")
        }

        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2.0
        self.avatarImageView.layer.masksToBounds = true
        
        if let createdAt = notification.created_at {
            self.timeLabel.text = createdAt.formattedAsTimeAgo()
        }
        
        // Like
        if notification.type == 0 {
            if notification.post?.postHeader != nil || (notification.post?.postHeader?.isEmpty)! {
                self.titleLabel.text = (notification.sender?.userName)! + " liked your post: \"" + (notification.post?.postHeader)! + "\""
                print("Like..............")
            }
        }
        
        //Comment.
        else if notification.type == 1 {
            if notification.post?.postHeader != nil || (notification.post?.postHeader?.isEmpty)! {
                self.titleLabel.text = (notification.sender?.userName)! + " commented your post: \"" + (notification.post?.postHeader)! + "\""
                print("Comment..............")
            }
        }
        
        //Join
        else if notification.type == 2 {
            if notification.pod?.name != nil || (notification.pod?.name?.isEmpty)! {
                self.titleLabel.text = (notification.sender?.userName)! + " joined as a member in your pod: \"" + (notification.pod?.name)! + "\""
                print("Join..............")
            }
        }
        
        //Withdraw
        else if notification.type == 3 {
            if notification.pod?.name != nil || (notification.pod?.name?.isEmpty)! {
                self.titleLabel.text = (notification.sender?.userName)! + " withdrew as a member in your pod: \"" + (notification.pod?.name)! + "\""
                print("Withdraw..............")
            }
        }
        
        //Added you
        else if notification.type == 4 {
            if notification.pod?.name != nil || (notification.pod?.name?.isEmpty)! {
                self.titleLabel.text = (notification.sender?.userName)! + " added you as a member in this pod: \"" + (notification.pod?.name)! + "\""
                print("Added you..............")
            }
        }
        
        let longestWordRange = (self.titleLabel.text! as NSString).rangeOfString((notification.sender?.userName)!)
        let attributedString = NSMutableAttributedString(string: self.titleLabel.text!, attributes: [NSFontAttributeName : UIFont(name: Constants.Fonts.Raleway_Regular, size: 14.0)!])
        attributedString.setAttributes([NSFontAttributeName : UIFont(name: Constants.Fonts.Raleway_Bold, size: 14.0)! , NSForegroundColorAttributeName : UIColor.blackColor()], range: longestWordRange)
        self.titleLabel.attributedText = attributedString

    }
    
}
