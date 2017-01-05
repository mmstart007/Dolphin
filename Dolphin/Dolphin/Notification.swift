//
//  Notification.swift
//  Dolphin
//
//  Created by Ninth Coast on 9/1/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notification : NSObject {
    
    var notification_id: Int?
    var created_at: Date?
    var is_read: Bool?
    var object_id: Int?
    var receiver_id: Int?
    var type: Int?
    var user_id: Int?
    var sender: User?
    var pod: POD?
    var post: Post?
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        self.notification_id        = jsonObject["notification_id"].intValue
        if let createdAtString         = jsonObject["created_at"].double {
            self.created_at             = Date(timeIntervalSince1970: createdAtString) //Double(createdAtString)!)
        }
        
        self.is_read                = jsonObject["is_read"].boolValue
        self.object_id              = jsonObject["object_id"].intValue
        self.receiver_id            = jsonObject["receiver_id"].intValue
        self.type                   = jsonObject["type"].intValue
        self.user_id                = jsonObject["user_id"].intValue
        
        let userJson = jsonObject["user"].arrayValue
        if userJson.count > 0 {
            for users in userJson {
                self.sender  = User(jsonObject: users)
            }
        }
        let postJson = jsonObject["post"].arrayValue
        if  postJson.count > 0 {
            for posts in userJson {
                self.post  = Post(jsonObject: posts)
            }
        }
        let podJson = jsonObject["pod"].arrayValue
        if podJson.count > 0 {
            for pods in podJson {
                self.pod  = POD(jsonObject: pods)
            }
        }
    }

//    func toJson() -> [String: AnyObject] {
//        var retDic: [String: AnyObject] = [:]
//        retDic["id"] = self.id
//        retDic["name"] = self.name
//        return retDic
//    }
}
