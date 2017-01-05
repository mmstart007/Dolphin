//
//  Image.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/14/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Image : NSObject {
    
    var id: Int?
    var imageURL: String?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        self.id       = jsonObject["id"].intValue
        self.imageURL = jsonObject["image_url"].stringValue
        self.imageWidth = CGFloat(jsonObject["image_width"].floatValue)
        self.imageHeight = CGFloat(jsonObject["image_height"].floatValue)
    }
    
    
}
