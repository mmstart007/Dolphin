//
//  PostType.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/14/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class PostType : NSObject {
    
    var id: Int?
    var name: String?
    
    convenience init(name: String) {
        self.init()
        
        self.name = name
    }
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        self.id   = jsonObject["id"].intValue
        self.name = jsonObject["name"].stringValue
    }
}
