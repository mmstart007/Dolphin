
//
//  CustomFontCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/23/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class CustomFontCollectionViewCell : UICollectionViewCell {
    
    override func layoutSubviews() {
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}