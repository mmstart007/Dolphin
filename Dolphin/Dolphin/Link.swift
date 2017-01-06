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
    
    init(url: String, imageURL: String) {
        //self.init()
        
        self.url = url
        self.imageURL = imageURL
    }
    
    init(jsonObject: JSON) {
        //self.init()
        
        id       = jsonObject["id"].intValue
        url      = jsonObject["url"].stringValue
        imageURL = jsonObject["image_url"].stringValue
        imageWidth = CGFloat(jsonObject["image_width"].floatValue)
        imageHeight = CGFloat(jsonObject["image_height"].floatValue)
    }
    
    
}
