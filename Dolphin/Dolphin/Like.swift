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
    var likeDate: Date?
    var likeUser: User?
    var likePost: Post?
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        let likeJsonObject       = jsonObject as? [String: AnyObject]
        self.likeUser            = User(jsonObject: likeJsonObject!["user"] as! [String: AnyObject] as AnyObject)
        self.id                  = likeJsonObject!["id"] as? Int
        self.likePost            = Post(jsonObject: likeJsonObject!["post"] as! [String: AnyObject] as AnyObject)
        let dateString           = likeJsonObject!["created_at"] as? String
        self.likeDate            = Date(timeIntervalSince1970: Double(dateString!)!)
    }    
    
}
