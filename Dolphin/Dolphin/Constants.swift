//
//  Constants.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Constants {
    
    struct RESTAPIConfig {
        struct Developement {
            static let BaseUrl: String = "http://dolphin-api.ninthcoast.com/"
        }
    }
    
    struct KeychainConfig {
        static let Service: String = "DolphinService"
        static let Account: String = "com.dolphin.keychain"
        static let TokenLabel: String = "Token"
    }
    
}