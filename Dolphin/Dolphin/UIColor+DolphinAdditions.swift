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
    
    class func topicsColorsArray() -> [UIColor] {
        let color1 = UIColor(red: 255.0/255.0, green: 180.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 109.0/255.0, green: 207.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        let color3 = UIColor(red: 163.0/255.0, green: 211.0/255.0, blue: 156.0/255.0, alpha: 1.0)
        let color4 = UIColor(red: 253.0/255.0, green: 198.0/255.0, blue: 137.0/255.0, alpha: 1.0)
        let color5 = UIColor(red: 161.0/255.0, green: 134.0/255.0, blue: 190.0/255.0, alpha: 1.0)

        return [color1, color2, color3, color4, color5]
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
    
    class func lighterColorForColor(color: UIColor) -> (UIColor) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red   = min(red + 0.2, 1.0)
        blue  = min(blue + 0.2, 1.0)
        green = min(green + 0.2, 1.0)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func darkerColorForColor(color: UIColor) -> (UIColor) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red   = min(red - 0.2, 1.0)
        blue  = min(blue - 0.2, 1.0)
        green = min(green - 0.2, 1.0)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
