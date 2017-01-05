//
//  Link.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/18/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Link : NSObject {
    
    var id: Int?
    var url: String?
    var imageURL: String?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    
    convenience init(url: String, imageURL: String) {
        self.init()
        
        self.url = url
        self.imageURL = imageURL
    }
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        self.id       = jsonObject["id"].intValue
        self.url      = jsonObject["url"].stringValue
        self.imageURL = jsonObject["image_url"].stringValue
        self.imageWidth = CGFloat(jsonObject["image_width"].floatValue)
        self.imageHeight = CGFloat(jsonObject["image_height"].floatValue)
    }
    
    
}
