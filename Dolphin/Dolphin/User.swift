//
//  User.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class User : NSObject {
    
    var userName: String?
    var userImageURL: String?
    
    init(name: String, imageURL: String) {
        self.userName     = name
        self.userImageURL = imageURL
    }
    
}