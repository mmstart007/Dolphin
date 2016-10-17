//
//  PODRequest.swift
//  Dolphin
//
//  Created by Mobi Soft on 10/7/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class PODRequest : NSObject {
    
    
    var id: Int?
    var name: String?
    var descriptionText: String?
    var imageData: UIImage?
    var isPrivate: Int?
    var users: [User]?
    var image_width : Int?
    var image_height : Int?
    
    
    convenience init(name: String?, description: String?, isPrivate: Int?, users: [User], imageData: UIImage?, image_width: Int?, image_height: Int?) {
        
        self.init()
        
        self.name            = name
        self.descriptionText = description
        self.isPrivate       = isPrivate
        self.users           = users
        self.imageData       = imageData
        self.image_width     = image_width
        self.image_height    = image_height
        
    }
    
    
    func toJson() -> [String: AnyObject] {
        var retDic = [String: AnyObject]()
        if let podId = self.id {
            retDic["id"] = podId
        }
        
        if let nm = self.name {
            retDic["name"] = nm
        }
        if let descrip = self.descriptionText {
            retDic["description"] = descrip
        }
        if let image = self.imageData {
            retDic["image"] = Utils.encodeBase64(image)
        }
        if let priv = self.isPrivate {
            retDic["is_private"] = priv
        }
        if let width = self.image_width {
            retDic["image_width"] = width
        }
        if let height = self.image_height {
            retDic["image_height"] = height
        }
        
        
        if let usrs = self.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds
        }
        
        return retDic
    }
    
}
