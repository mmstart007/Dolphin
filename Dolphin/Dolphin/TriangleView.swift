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
    
    var color: UIColor = UIColor.red
    
    override func draw(_ rect: CGRect) {
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.beginPath()
        ctx.move   (to: CGPoint(x: rect.minX, y: rect.minY));  // top left
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY));  // mid right
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY));  // bottom left
        ctx.closePath();

        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            ctx.setFillColor(red: fRed, green: fGreen, blue: fBlue, alpha: fAlpha)
        }
        
        ctx.fillPath();
    }
    
    func addImage(_ name: String) {
        let image = UIImage(named: name)
        let imageView = UIImageView(frame: CGRect(x: self.frame.size.width * (5 / 9), y: self.frame.size.height * (1 / 5), width: self.frame.size.width / 3, height: self.frame.size.width / 3))
        imageView.image = image
        addSubview(imageView)
    }
    
}
