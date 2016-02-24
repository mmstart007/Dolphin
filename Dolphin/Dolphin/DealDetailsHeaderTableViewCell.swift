//
//  DealDetailsHeaderTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/17/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class DealDetailsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewDealImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLink: UILabel!
    
    
    func configureWithDeal(deal: Deal) {
        imageViewDealImage.sd_setImageWithURL(NSURL(string: (deal.dealImage)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        labelTitle.text = deal.dealDescription
        labelLink.text = "http://digitalsynopsis.com/inspiration/privileged-kids-0..."
        backgroundColor = UIColor.lightGrayBackground()
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}
