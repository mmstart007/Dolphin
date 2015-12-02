//
//  UIColor+DolphinAdditions.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

extension UIColor {
    
    class func blueDolphin() -> UIColor {
        return UIColor(red: 27.0/255.0, green: 61.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    }
    
    class func yellowHighlightedMenuItem() -> UIColor {
        return UIColor(red: 252.0/255.0, green: 226.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
}
