//
//  User.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class User : NSObject {
    
    var id: Int?
    var deviceId: String?
    var userName: String?
    var userImageURL: String?
    var userEmail: String?
    var userPassword: String?
    
    convenience init(deviceId: String?, name: String?, imageURL: String?, email: String?, password: String?) {
        self.init()
        self.deviceId     = deviceId
        self.userName     = name
        self.userImageURL = imageURL
        self.userEmail    = email
        self.userPassword = password
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.deviceId     = jsonObject["device_id"] as? String
        self.userName     = jsonObject["name"] as? String
        self.userImageURL = jsonObject["avatar_image_url"] as? String
        self.userEmail    = jsonObject["email"] as? String
        self.userPassword = jsonObject["password"] as? String
        self.id           = jsonObject["id"] as? Int
        
    }
    
    func toJson() -> [String: String] {
        return ["device_id": self.deviceId!,
            "name": self.userName!,
            "avatar_image": self.userImageURL!,
            "email": self.userEmail!,
            "password": self.userPassword!]
    }
    
}