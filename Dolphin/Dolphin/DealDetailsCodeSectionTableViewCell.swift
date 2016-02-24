//
//  DealDetailsCodeSectionTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/18/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class DealDetailsCodeSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCode: UIImageView!
    @IBOutlet weak var textViewDescription: UITextView!
 
    func configureWithDeal(deal: Deal) {
        if !deal.dealCodeUrl!.isEmpty {
            imageViewCode.sd_setImageWithURL(NSURL(string: (deal.dealCodeUrl)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        }
        backgroundColor = UIColor.lightGrayBackground()
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}
