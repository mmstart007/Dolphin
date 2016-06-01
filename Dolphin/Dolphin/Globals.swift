//
//  Globals.swift
//  Dolphin
//
//  Created by Joachim on 5/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

public class Globals: NSObject {
    
    static var currentLat: Double = 0.0
    static var currentLng: Double = 0.0
    static var currentAddress: String = ""
    
    // Convert from NSData to json object
    public static func nsdataToJSON(data: NSData) -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    // Convert from JSON to nsdata
    public static func jsonToNSData(json: AnyObject) -> NSData?{
        do {
            return try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
}