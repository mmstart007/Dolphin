//
//  AddressBookContact.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/29/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class AddressBookContact {
    
    var userName: String!
    var userImage: UIImage?
    var userId: String!
    var userPhone: [String]
    var userEmail: [String]
    
    init(name: String!, image: UIImage?, user_id: String!, phone: [String], email: [String]) {
        self.userName  = name
        self.userImage = image
        self.userId    = user_id
        self.userPhone = phone
        self.userEmail = email
    }
    
}