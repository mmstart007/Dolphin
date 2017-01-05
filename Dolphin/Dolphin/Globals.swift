//
//  Globals.swift
//  Dolphin
//
//  Created by Ninth Coast on 5/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Globals: NSObject {
    
    static var currentLat: Double = 0.0
    static var currentLng: Double = 0.0
    static var currentDeviceToken: String   = ""
    static var currentCity: String          = ""
    static var currentCountry: String       = ""
    static var currentZip: String           = ""
    static var currentAddress: String       = ""
    
    // Convert from NSData to json object
    open static func nsdataToJSON(_ data: Data) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            //return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    // Convert from JSON to nsdata
    open static func jsonToNSData(_ json: AnyObject) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
 }
