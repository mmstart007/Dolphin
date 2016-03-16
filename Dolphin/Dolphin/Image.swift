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
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.id       = jsonObject["id"] as? Int
        self.imageURL = jsonObject["image_url"] as? String
    }


}