//
//  NSURL+DolphinExtensions.swift
//  Dolphin
//
//  Created by Ninth Coast on 4/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

extension URL {
    
    var queryItems:[String: String]? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (params: [String: String], item) -> [String: String] in
                var tmpParams = params
                tmpParams[item.name] = item.value
                return tmpParams
            })
    }
}
