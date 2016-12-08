//
//  FriendToInviteTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/28/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import PinterestSDK

@objc protocol FriendToInviteTableViewCellDelegate{
    @objc optional func inviteFriend(_ friend: AnyObject, type: Int)
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
        friendImageView.backgroundColor     = UIColor.clear
        inviteButton.layer.cornerRadius     = 5

        inviteButton.addTarget(self, action: #selector(FriendToInviteTableViewCell.actionInvite(_:)), for: UIControlEvents.touchUpInside)

    }
    
    func configureWithFacebookFriend(_ friend: FacebookFriend) {
        friendMember = friend
        type = Constants.InviteType.Invite_Facebook
        
        friendImageView.sd_setImage(with: URL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithTwitterFriend(_ friend: TwitterFriend) {
        friendMember = friend
        type = Constants.InviteType.Invite_Twitter
        
        friendImageView.sd_setImage(with: URL(string: friend.userImageURL), placeholderImage: UIImage(named: "UserPlaceholder"))
        friendNameLabel.text = friend.userName
    }
    
    func configureWithAddressBookContact(_ contact: AddressBookContact) {
        friendMember = contact
        type = Constants.InviteType.Invite_Contact
        
        if contact.userImage == nil {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.image = contact.userImage
        }
        friendNameLabel.text = contact.userName
    }
    
    func configureWithPinterestFriend(_ friend: PDKUser) {
        friendMember = friend
        type = Constants.InviteType.Invite_Instagram
        friendNameLabel.text = friend.firstName + friend.lastName
        if friend.images != nil {
            let url = (friend.images.values.first! as! [String: Any])["url"] as! String
            
//            let url = Array(friend.images.values)[0]["url"] as! String
            friendImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        else {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        }
    }
    
    func configureWithPODMember(_ member: User) {
        if member.userAvatarImageURL == "" {
            friendImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            friendImageView.sd_setImage(with: URL(string: member.userAvatarImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        friendNameLabel.text = member.userName
        inviteButton.isHidden = true
    }
    
    @IBAction func actionInvite(_ sender: AnyObject) {
        if friendMember != nil {
            self.delegate?.inviteFriend!(friendMember!, type: type!)
        }
    }
    
}
