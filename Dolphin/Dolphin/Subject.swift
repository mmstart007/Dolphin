//
//  Subject.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/29/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class Subject : NSObject {
    
    var id: Int?
    var name: String?
    
    init(name: String) {
        //self.init()
        
        self.name = name
    }
    
    init(jsonObject: JSON) {
        //self.init()
        
        id       = jsonObject["id"].intValue
        name      = jsonObject["name"].stringValue
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = [:]
        retDic["id"] = self.id as AnyObject?
        retDic["name"] = self.name as AnyObject?
        return retDic
    }
    
}
