//
//  PODMemberToAddTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PODMemberToAddTableViewCellDelegate {
    @objc optional func deleteMember(_ user: User?, index: Int)
    @objc optional func addMember(_ user: User?, index: Int)
}

class PODMemberToAddTableViewCell : UITableViewCell {
    
    var index: Int = 0
    var selectedUser: User!
    var isMember: Bool!
    var delegate:PODMemberToAddTableViewCellDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        
        actionButton.layer.masksToBounds = true
        actionButton.layer.cornerRadius = 3.0
    }
    
    func configureWithUser(_ user: User, isAdded: Bool, index: Int) {

        self.index = index
        self.selectedUser = user
        self.isMember = isAdded
        
        if user.userAvatarImageURL == nil || user.userAvatarImageURL == "" {
            userImageView.image = UIImage(named: "UserPlaceholder")
        } else {
            userImageView.sd_setImage(with: URL(string: user.userAvatarImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        }
        userNameLabel.text = user.userName
        
        if isAdded {
            actionButton.backgroundColor = UIColor.redDolphin()
            actionButton.setTitle("Delete", for: UIControlState())
            
        } else {
            actionButton.backgroundColor = UIColor.greenDolphinDealHeader()
            actionButton.setTitle("Add", for: UIControlState())
        }
    }
    
    @IBAction func didTapAction() {
        //Delete
        if self.isMember == true {
            self.delegate?.deleteMember!(self.selectedUser, index:index)
        }
        else {
            self.delegate?.addMember!(self.selectedUser, index:index)
        }
    }
}
