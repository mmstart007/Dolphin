//
//  Link.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/18/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Link : NSObject {
    
    var id: Int?
    var url: String?
    var imageURL: String?
    
    convenience init(url: String, imageURL: String) {
        self.init()
        
        self.url = url
        self.imageURL = imageURL
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.id       = jsonObject["id"] as? Int
        self.url      = jsonObject["url"] as? String
        self.imageURL = jsonObject["image_url"] as? String
    }
    
    
}