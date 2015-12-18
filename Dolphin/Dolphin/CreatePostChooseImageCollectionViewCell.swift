//
//  CreatePostChooseImageCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/10/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreatePostChooseImageCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configureWithImageURL(url: String) {
        imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        imageView.contentMode = .ScaleAspectFit
    }
    
    func configureWithImage(image: UIImage) {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
    }
}
