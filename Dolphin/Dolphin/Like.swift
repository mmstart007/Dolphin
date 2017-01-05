//
//  Like.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/15/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Like : NSObject {
    
    var id: Int?
    var likeDate: Date?
    var likeUser: User?
    var likePost: Post?
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        let likeJsonObject       = jsonObject
        self.likeUser            = User(jsonObject: likeJsonObject["user"])
        self.id                  = likeJsonObject["id"].intValue
        self.likePost            = Post(jsonObject: likeJsonObject["post"])
        let dateString           = likeJsonObject["created_at"].stringValue
        self.likeDate            = Date(timeIntervalSince1970: Double(dateString)!)
    }    
    
}
