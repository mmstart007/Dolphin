//
//  GridPostCell.swift
//  Dolphin
//
//  Created by star on 7/27/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class GridPostCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configurePost(_ p: Post) {
        if let image = p.postImage {
            self.photoImageView.sd_setImage(with: URL(string: (image.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            self.photoImageView.isHidden = false
            self.titleLabel.isHidden = true
        }
        else if let linkImage = p.postLink {
            self.photoImageView.sd_setImage(with: URL(string: (linkImage.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            self.photoImageView.isHidden = false
            self.titleLabel.isHidden = true
        }
        else {
            self.titleLabel.text = p.postHeader
            self.photoImageView.isHidden = true
            self.titleLabel.isHidden = false
        }
    }
}
