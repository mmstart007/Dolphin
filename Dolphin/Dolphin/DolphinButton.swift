//
//  DolphinButton.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/2/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class DolphinButton : UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = imageView?.image {
            
            let margin = 20 - image.size.width / 2
            let titleRect = self.titleRect(forContentRect: bounds)
            
            contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            imageEdgeInsets = UIEdgeInsetsMake(0, margin, 0, 0)
            titleEdgeInsets = UIEdgeInsetsMake(0, (bounds.width - titleRect.width -  image.size.width - margin) / 2, 0, 0)
        }
        
    }

    
}
