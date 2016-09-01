//
//  Notification.swift
//  Dolphin
//
//  Created by Joachim on 9/1/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Notification : NSObject {
    
    var notification_id: Int?
    var created_at: NSDate?
    var is_read: Bool?
    var object_id: Int?
    var receiver_id: Int?
    var type: Int?
    var user_id: Int?
    var sender: User?
    var pod: POD?
    var post: Post?
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.notification_id        = jsonObject["notification_id"] as? Int
        if let createdAtString         = jsonObject["created_at"] as? String {
            self.created_at             = NSDate(timeIntervalSince1970: Double(createdAtString)!)
        }
        
        self.is_read                = jsonObject["is_read"] as? Bool
        self.object_id              = jsonObject["object_id"] as? Int
        self.receiver_id            = jsonObject["receiver_id"] as? Int
        self.type                   = jsonObject["type"] as? Int
        self.user_id                = jsonObject["user_id"] as? Int
        if let userJson = jsonObject["user"] as? [String: AnyObject] {
            self.sender  = User(jsonObject: userJson)
        }

        if let postJson = jsonObject["post"] as? [String: AnyObject] {
            self.post  = Post(jsonObject: postJson)
        }
        
        if let podJson = jsonObject["pod"] as? [String: AnyObject] {
            self.pod  = POD(jsonObject: podJson)
        }
    }
    
//    func toJson() -> [String: AnyObject] {
//        var retDic: [String: AnyObject] = [:]
//        retDic["id"] = self.id
//        retDic["name"] = self.name
//        return retDic
//    }
}
