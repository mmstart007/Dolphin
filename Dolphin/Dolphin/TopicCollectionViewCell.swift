//
//  TopicCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class TopicCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var topicNameLabel: UILabel!
    
    func configureWithName(name: String, color: UIColor) {
        self.topicNameLabel.text = name
        self.layer.cornerRadius  = 10
        self.backgroundColor     = color
        self.layer.borderColor   = UIColor.darkerColorForColor(color).CGColor
        self.layer.borderWidth   = 2
    }
    
}