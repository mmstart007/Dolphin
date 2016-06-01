//
//  Image.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/14/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Image : NSObject {
    
    var id: Int?
    var imageURL: String?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.id       = jsonObject["id"] as? Int
        self.imageURL = jsonObject["image_url"] as? String
        self.imageWidth = jsonObject["image_width"] as? CGFloat
        self.imageHeight = jsonObject["image_height"] as? CGFloat
    }
    
    
}