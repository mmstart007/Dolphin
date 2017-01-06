//
//  Topic.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/14/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Topic : NSObject {
    
    var id: Int?
    var name: String?
    
    init(name: String) {
        //self.init()
        
        self.name = name
    }
    
    init(jsonObject: JSON) {
        //self.init()
        
        id   = jsonObject["id"].intValue
        name = jsonObject["name"].stringValue
    }
    
    func toJson() -> [String: String] {
        return ["name": self.name!]
        
        
    }
    
    
}
