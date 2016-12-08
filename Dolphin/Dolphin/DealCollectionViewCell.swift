//
//  DealCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/9/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DealCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var dealDescriptionLabel: UILabel!
    @IBOutlet weak var dealDateLabel: UILabel!
    var triangleView: TriangleView?
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            let separation: CGFloat = 6.0
            frame.origin.x          += separation
            frame.origin.y          += separation
            frame.size.width        = frame.size.width - (separation * 2.0)
            frame.size.height       = frame.size.height - (separation * 2.0)
            super.frame             = frame
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
    }
    
    func configureWithDeal(_ deal: Deal) {
        
        if deal.dealImage != nil {
            dealImageView.sd_setImage(with: URL(string: deal.dealImage!))
        }
        dealDescriptionLabel.text = deal.dealDescription
        dealDateLabel.text        = deal.dealDate?.formattedAsTimeAgo()
        dealDescriptionLabel.numberOfLines = 0
        dealDescriptionLabel.sizeToFit()
        
    }
    
    func configureAsDealsHeader() {
        dealImageView.image = UIImage(named: "DolphinDealHeader")
        dealDescriptionLabel.text = "List your Deal for other Dolphins to Explore!"
        dealDescriptionLabel.textAlignment = .center
        dealDescriptionLabel.numberOfLines = 0
        dealDescriptionLabel.adjustsFontSizeToFitWidth = true
        
        if triangleView == nil {
            triangleView        = TriangleView()
            triangleView!.frame = CGRect(x: self.frame.size.width - 60, y: 0, width: 60, height: 60)
        }
        triangleView?.isHidden             = false
        triangleView!.color              = UIColor.greenDolphinDealHeader()
        triangleView!.backgroundColor    = UIColor.clear
        triangleView!.layer.cornerRadius = 5
        self.addSubview(triangleView!)
        triangleView!.addImage("DollarIcon")
    }
}
