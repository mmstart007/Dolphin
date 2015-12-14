//
//  TriangleView.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class TriangleView : UIView {
    
    var color: UIColor = UIColor.redColor()
    
    override func drawRect(rect: CGRect) {
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextBeginPath(ctx)
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
        CGContextClosePath(ctx);

        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            CGContextSetRGBFillColor(ctx, fRed, fGreen, fBlue, fAlpha)
        }
        
        CGContextFillPath(ctx);
    }
    
    func addImage(name: String) {
        let image = UIImage(named: name)
        let imageView = UIImageView(frame: CGRect(x: self.frame.size.width * (5 / 9), y: self.frame.size.height * (1 / 5), width: self.frame.size.width / 3, height: self.frame.size.width / 3))
        imageView.image = image
        addSubview(imageView)
    }
    
}
