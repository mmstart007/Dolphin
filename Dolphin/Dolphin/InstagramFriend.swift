//
//  InstagramFriend.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/31/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class InstagramFriend {
    
    var userName: String!
    var userImageURL: String!
    var userId: String!
    
    init(name: String!, imageURL: String!, user_id: String!) {
        self.userName     = name
        self.userImageURL = imageURL
        self.userId       = user_id
    }
    
}
