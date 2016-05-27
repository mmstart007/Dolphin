//
//  NSURL+DolphinExtensions.swift
//  Dolphin
//
//  Created by Ninth Coast on 4/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

extension NSURL {
    var queryItems: [String: String]? {
        return NSURLComponents(URL: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], combine: { (var params: [String: String], item) -> [String: String] in
                params[item.name] = item.value
                return params
            })
    }
}