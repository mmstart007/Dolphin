//
//  User.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    var grades: [Grade]?  = []
    var subjects: [Subject]? = []
    var gender: Int?
    var city: String?
    var country: String?
    var zip: String?
    
    init(deviceId: String?, userName: String?, imageURL: String?, email: String?, password: String?, gender: Int?, city: String?, country: String?, zip: String?, location: String?) {
        //self.init()
        self.deviceId           = deviceId
        self.userName           = userName
        self.userAvatarImageURL = imageURL
        self.userEmail          = email
        self.userPassword       = password
        self.gender             = gender
        self.city               = city
        self.country            = country
        self.zip                = zip
        self.location           = location
    }
    
    init(jsonObject: JSON) {
        //self.init()
        
        userEmail          = jsonObject["email"].stringValue
        userName           = jsonObject["username"].stringValue
        firstName          = jsonObject["first_name"].stringValue
        lastName           = jsonObject["last_name"].stringValue
        location           = jsonObject["location"].stringValue
        isPrivate          = jsonObject["is_private"].intValue
        id                 = jsonObject["id"].intValue
        userAvatarImageURL = jsonObject["avatar_image_url"].stringValue
        gender             = jsonObject["gender"].intValue
        city               = jsonObject["city"].stringValue
        country            = jsonObject["country"].stringValue
        zip                = jsonObject["zip"].stringValue

        if let arrayGrades = jsonObject["grades"].array
        {
            for item in arrayGrades {
                let g = Grade(jsonObject: item)
                self.grades?.append(g)
            }
        }
        
        if let arraySubjects = jsonObject["subjects"].array
        {
            for item in arraySubjects {
                let s = Subject(jsonObject: item)
                self.subjects?.append(s)
            }
        }
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = [:]
        
        if self.deviceId != nil {
            retDic["device_id"] = self.deviceId! as AnyObject?
        }
        
        if let uname = self.userName {
            retDic["username"] = uname as AnyObject?
        }
        if let mail = self.userEmail {
            retDic["email"] = mail as AnyObject?
        }
        if let pass = self.userPassword {
            retDic["password"] = pass as AnyObject?
        }
        if let fName = self.firstName {
            retDic["first_name"] = fName as AnyObject?
        }
        if let lName = self.lastName {
            retDic["last_name"] = lName as AnyObject?
        }
        if let loc = self.location {
            retDic["location"] = loc as AnyObject?
        }
        if let priv = self.isPrivate {
            retDic["is_private"] = priv as AnyObject?
        }
        if let image = self.userAvatarImageData {
            retDic["avatar_image"] = Utils.encodeBase64(image) as AnyObject?
        }
        if let image_url = self.userAvatarImageURL {
            retDic["avatar_image_url"] = image_url as AnyObject?
        }
        if let gender = self.gender {
            retDic["gender"] = gender as AnyObject?
        }
        if let city = self.city {
            retDic["city"] = city as AnyObject?
        }
        if let country = self.country {
            retDic["country"] = country as AnyObject?
        }
        if let zip = self.zip {
            retDic["zip"] = zip as AnyObject?
        }
        
        if self.subjects != nil {
            
            var array: [AnyObject] = []
            for item in self.subjects! {
                array.append(item.toJson() as AnyObject)
            }
            
            retDic["subjects"] = array as AnyObject?
        }
        
        if self.grades != nil {
            
            var array: [AnyObject] = []
            for item in self.grades! {
                array.append(item.toJson() as AnyObject)
            }
            
            retDic["grades"] = array as AnyObject?
        }
        return retDic
    }
    
    
    func getSubjectIds() -> [String] {
        
        var subject_ids: [String] = []
        
        if(self.subjects != nil)
        {
            for item in self.subjects! {
                subject_ids.append(String(format: "%d", item.id!))
            }
        }
        
        return subject_ids
    }
    
    func getSubjectNames() -> String {
        var subject_name: [String] = []
        
        if(self.subjects != nil)
        {
            for item in self.subjects! {
                subject_name.append(item.name!)
            }
        }
        return subject_name.joined(separator: ",")
    }
    
    func getGradeIds() -> [String] {
        
        var grade_ids: [String] = []
        
        if(self.grades != nil)
        {
            for item in self.grades! {
                grade_ids.append(String(format: "%d", item.id!))
            }
        }
        
        return grade_ids
    }
    
    func getGradeNames() -> String {
        var grade_name: [String] = []
        
        if(self.grades != nil)
        {
            for item in self.grades! {
                grade_name.append(item.name!)
            }
        }
        return grade_name.joined(separator: ",")
    }
    
}
