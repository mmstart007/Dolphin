//
//  FriendToInviteTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/28/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class FriendToInviteTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendImageView.layer.cornerRadius  = friendImageView.frame.size.width / 2.0
        friendImageView.layer.masksToBounds = true
        friendImageView.backgroundColor     = UIColor.clearColor()
        inviteButton.layer.cornerRadius     = 10
    }
    
    func configureWithFacebookFriend(friend: FacebookFriend) {
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithTwitterFriend(friend: TwitterFriend) {
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithAddressBookContact(contact: AddressBookContact) {
        if contact.userImage == nil {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.image = contact.userImage
        }
        friendNameLabel.text = contact.userName
    }
    
    func configureWithInstagramFriend(friend: InstagramFriend) {
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithPODMember(member: User) {
        if member.userImageURL == "" {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.sd_setImageWithURL(NSURL(string: member.userImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        friendNameLabel.text = member.userName
        inviteButton.hidden = true
    }
    
}