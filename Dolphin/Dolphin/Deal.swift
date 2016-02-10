//
//  Deal.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/9/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Deal {
    
    var dealImage: String?
    var dealDescription: String?
    var dealDate: NSDate?
    
    convenience init (image: String, description: String, date: NSDate) {
        self.init()
        
        dealImage       = image
        dealDescription = description
        dealDate        = date
        
    }
    
}