//
//  POD.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class POD : NSObject {
    
    var podName: String?
    var podImageURL: String?
    var podLastPostDate: NSDate?
    var podUsers: [User]?
    
    init(name: String, imageURL: String, lastpostDate: NSDate, users: [User]) {
        self.podName         = name
        self.podImageURL     = imageURL
        self.podLastPostDate = lastpostDate
        self.podUsers        = users
    }
    
}