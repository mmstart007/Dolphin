//
//  CustomFontTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/23/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class CustomFontTableViewCell : UITableViewCell {
    
    override func layoutSubviews() {
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}
