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
    var podIsPrivate: Bool
    
    init(name: String, imageURL: String, lastpostDate: NSDate, users: [User], isPrivate: Bool) {
        self.podName         = name
        self.podImageURL     = imageURL
        self.podLastPostDate = lastpostDate
        self.podUsers        = users
        self.podIsPrivate    = isPrivate
    }
    
    func podColor() -> UIColor {
        let color = Int(arc4random_uniform(3))
        let colors = [UIColor(red: 155/255.0, green: 230/255.0, blue: 88/255.0, alpha: 1), UIColor(red: 40/255.0, green: 231/255.0, blue: 216/255.0, alpha: 1),
            UIColor(red: 232/255.0, green: 97/255.0, blue: 39/255.0, alpha: 1)]
        return colors[color]
    }
    
}