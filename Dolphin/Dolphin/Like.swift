//
//  Like.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/15/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Like : NSObject {
    
    var id: Int?
    var likeDate: NSDate?
    var likeUser: User?
    var likePost: Post?
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        let likeJsonObject       = jsonObject as? [String: AnyObject]
        self.likeUser            = User(jsonObject: likeJsonObject!["user"] as! [String: AnyObject])
        self.id                  = likeJsonObject!["id"] as? Int
        self.likePost            = Post(jsonObject: likeJsonObject!["post"] as! [String: AnyObject])
        let dateString           = likeJsonObject!["created_at"] as? String
        self.likeDate            = NSDate(timeIntervalSince1970: Double(dateString!)!)
    }    
    
}