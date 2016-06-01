//
//  FriendToInviteTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/28/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FriendToInviteTableViewCellDelegate{
    optional func inviteFriend(friend: AnyObject, type: Int)
}

class FriendToInviteTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    var friendMember: AnyObject?
    var type: Int?
    var delegate: FriendToInviteTableViewCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendImageView.layer.cornerRadius  = friendImageView.frame.size.width / 2.0
        friendImageView.layer.masksToBounds = true
        friendImageView.backgroundColor     = UIColor.clearColor()
        inviteButton.layer.cornerRadius     = 5

        inviteButton.addTarget(self, action: "actionInvite:", forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    func configureWithFacebookFriend(friend: FacebookFriend) {
        friendMember = friend
        type = Constants.InviteType.Invite_Facebook
        
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithTwitterFriend(friend: TwitterFriend) {
        friendMember = friend
        type = Constants.InviteType.Invite_Twitter
        
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithAddressBookContact(contact: AddressBookContact) {
        friendMember = contact
        type = Constants.InviteType.Invite_Contact
        
        if contact.userImage == nil {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.image = contact.userImage
        }
        friendNameLabel.text = contact.userName
    }
    
    func configureWithInstagramFriend(friend: InstagramFriend) {
        friendMember = friend
        type = Constants.InviteType.Invite_Instagram
        
        friendImageView.sd_setImageWithURL(NSURL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithPODMember(member: User) {
        if member.userAvatarImageURL == "" {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.sd_setImageWithURL(NSURL(string: member.userAvatarImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        friendNameLabel.text = member.userName
        inviteButton.hidden = true
    }
    
    @IBAction func actionInvite(sender: AnyObject) {
        if friendMember != nil {
            self.delegate?.inviteFriend!(friendMember!, type: type!)
        }
    }
    
}