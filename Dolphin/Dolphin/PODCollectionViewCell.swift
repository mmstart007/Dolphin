//
//  PODCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podNameLabel: UILabel!
    
    func configureWithPOD(_ pod: POD) {
        podImageView.sd_setImage(with: URL(string: (pod.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        podImageView.contentMode = .scaleAspectFill
        self.podNameLabel.text   = pod.name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.podImageView.layer.cornerRadius = self.podImageView.frame.size.width / 2.0
        podImageView.clipsToBounds           = true
        podImageView.layer.masksToBounds     = true
        self.podImageView.layer.borderWidth  = 4
        self.podImageView.layer.borderColor  = UIColor.white.cgColor
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: -2.0, height: 0)
        self.layer.shadowRadius = 2
        self.layer.cornerRadius = self.frame.size.width / 2.0
    }
    
}
