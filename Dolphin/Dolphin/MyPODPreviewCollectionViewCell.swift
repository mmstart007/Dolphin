//
//  MyPODPreviewCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/14/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import NSDate_Time_Ago

class MyPODPreviewCollectionViewCell : CustomFontCollectionViewCell {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podTitleLabel: UILabel!
    @IBOutlet weak var userImagesContainerView: UIView!
    @IBOutlet weak var lastPostDateLabel: UILabel!
    @IBOutlet weak var createPODView: UIView!
    
    var pod: POD?
    
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
        if pod != nil {
            addUserImages(pod!)
        }
    }
    
    func configureWithPOD(pod: POD?) {
        self.pod = pod
        self.layer.cornerRadius          = 5
        if pod != nil {
            podImageView.layer.cornerRadius  = 5
            podImageView.layer.masksToBounds = true
            podImageView.sd_setImageWithURL(NSURL(string: pod!.imageURL!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            podTitleLabel.text = pod!.name
            if let lastPostDate = pod?.lastPostDate {
                lastPostDateLabel.text = lastPostDate.formattedAsTimeAgo()
            }
            
            createPODView.hidden = true
        } else {
            createPODView.hidden = false
        }
    }
    
    func addUserImages(pod: POD) {
        if self.pod != nil {
            let otherUsersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: userImagesContainerView.frame.size.width, height: userImagesContainerView.frame.size.height))
            otherUsersLabel.backgroundColor = UIColor.lightGrayColor()
            otherUsersLabel.textColor = UIColor.lightTextColor()
            otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
            otherUsersLabel.layer.masksToBounds = true
            otherUsersLabel.text = String(format: "+%li", arguments: [(pod.users?.count)!])
            otherUsersLabel.textAlignment = .Center
            otherUsersLabel.font = UIFont.systemFontOfSize(12)
            userImagesContainerView.addSubview(otherUsersLabel)
        }
    }
}