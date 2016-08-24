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
    var grades: [Grade]?  = []
    var subjects: [Subject]? = []
    var gender: Int?
    var city: String?
    var country: String?
    var zip: String?
    
    convenience init(deviceId: String?, userName: String?, imageURL: String?, email: String?, password: String?, gender: Int?, city: String?, country: String?, zip: String?, location: String?) {
        self.init()
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
        self.gender             = jsonObject["gender"] as? Int
        self.city               = jsonObject["city"] as? String
        self.country            = jsonObject["country"] as? String
        self.zip                = jsonObject["zip"] as? String

        let arrayGrades         = jsonObject["grades"] as? [NSDictionary]
        if(arrayGrades != nil)
        {
            for item in arrayGrades! {
                let g = Grade(jsonObject: item)
                self.grades?.append(g)
            }
        }
        
        let arraySubjects        = jsonObject["subjects"] as? [NSDictionary]
        if(arraySubjects != nil)
        {
            for item in arraySubjects! {
                let s = Subject(jsonObject: item)
                self.subjects?.append(s)
            }
        }
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = [:]
        
        if self.deviceId != nil {
            retDic["device_id"] = self.deviceId!
        }
        
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
        if let image_url = self.userAvatarImageURL {
            retDic["avatar_image_url"] = image_url
        }
        if let gender = self.gender {
            retDic["gender"] = gender
        }
        if let city = self.city {
            retDic["city"] = city
        }
        if let country = self.country {
            retDic["country"] = country
        }
        if let zip = self.zip {
            retDic["zip"] = zip
        }
        
        if self.subjects != nil {
            
            var array: [AnyObject] = []
            for item in self.subjects! {
                array.append(item.toJson())
            }
            
            retDic["subjects"] = array
        }
        
        if self.grades != nil {
            
            var array: [AnyObject] = []
            for item in self.grades! {
                array.append(item.toJson())
            }
            
            retDic["grades"] = array
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
        return subject_name.joinWithSeparator(",")
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
        return grade_name.joinWithSeparator(",")
    }
    
}