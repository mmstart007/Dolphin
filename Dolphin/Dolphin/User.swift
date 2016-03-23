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
    var userAvatarImageURL: String?
    var userAvatarImageData: UIImage?
    var firstName: String?
    var lastName: String?
    var location: String?
    var userEmail: String?
    var userPassword: String?
    var isPrivate: Int?
    
    convenience init(deviceId: String?, userName: String?, imageURL: String?, email: String?, password: String?) {
        self.init()
        self.deviceId           = deviceId
        self.userName           = userName
        self.userAvatarImageURL = imageURL
        self.userEmail          = email
        self.userPassword       = password
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.userEmail          = jsonObject["email"] as? String
        self.userName           = jsonObject["username"] as? String
        self.firstName          = jsonObject["first_name"] as? String
        self.lastName           = jsonObject["last_name"] as? String
        self.location           = jsonObject["location"] as? String
        self.isPrivate          = jsonObject["is_private"] as? Int
        self.id                 = jsonObject["id"] as? Int
        self.userAvatarImageURL = jsonObject["avatar_image_url"] as? String
        
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = ["device_id": self.deviceId!]
        if let uname = self.userName {
            retDic["username"] = uname
        }
        if let mail = self.userEmail {
            retDic["email"] = mail
        }
        if let pass = self.userPassword {
            retDic["password"] = pass
        }
        if let fName = self.firstName {
            retDic["first_name"] = fName
        }
        if let lName = self.lastName {
            retDic["last_name"] = lName
        }
        if let loc = self.location {
            retDic["location"] = loc
        }
        if let priv = self.isPrivate {
            retDic["is_private"] = priv
        }
        if let image = self.userAvatarImageData {
            retDic["avatar_image"] = Utils.encodeBase64(image)
        }
        return retDic
        
    }
    
}