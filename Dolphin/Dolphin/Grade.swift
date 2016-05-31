//
//  Grade.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/29/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Grade : NSObject {
    
    var id: Int?
    var name: String?
    
    convenience init(name: String) {
        self.init()
        
        self.name = name
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        self.id       = jsonObject["id"] as? Int
        self.name      = jsonObject["name"] as? String
    }
    
    
}