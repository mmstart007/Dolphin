//
//  MyPODPreviewCollectionViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/14/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class MyPODPreviewCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podTitleLabel: UILabel!
    @IBOutlet weak var userImagesContainerView: UIView!
    
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
        let triangleView                = TriangleView()
        triangleView.frame              = CGRect(x: self.frame.size.width - 30, y: 0, width: 30, height: 30)
        triangleView.color              = (pod?.podColor())!
        triangleView.backgroundColor    = UIColor.clearColor()
        triangleView.layer.cornerRadius = 5
        self.addSubview(triangleView)
    }
    
    func configureWithPOD(pod: POD) {
        self.pod = pod
        self.layer.cornerRadius          = 5
        podImageView.layer.cornerRadius  = 5
        podImageView.layer.masksToBounds = true
        podImageView.sd_setImageWithURL(NSURL(string: pod.podImageURL!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        podTitleLabel.text = pod.podName
    }
    
    func addUserImages(pod: POD) {
        for (var i = 0; (i < pod.podUsers?.count && i < 5); i++) {
            if i == 0 && pod.podUsers?.count > 5 {
                // Add Label that shows number of remaining users in POD
                let x: CGFloat = userImagesContainerView.frame.size.width - userImagesContainerView.frame.size.width / 6 - (CGFloat(i) * (userImagesContainerView.frame.size.width / 6 + userImagesContainerView.frame.size.width / 24))
                let otherUsersLabel = UILabel(frame: CGRect(x: x, y: 0, width: userImagesContainerView.frame.size.width / 6, height: userImagesContainerView.frame.size.width / 6))
                otherUsersLabel.backgroundColor = UIColor.lightGrayColor()
                otherUsersLabel.textColor = UIColor.lightTextColor()
                otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
                otherUsersLabel.layer.masksToBounds = true
                otherUsersLabel.text = String(format: "+%li", arguments: [(pod.podUsers?.count)! - 4])
                otherUsersLabel.textAlignment = .Center
                otherUsersLabel.font = UIFont.systemFontOfSize(12)
                userImagesContainerView.addSubview(otherUsersLabel)
            } else {
                // Sow image of user in POD
                let x: CGFloat = userImagesContainerView.frame.size.width - userImagesContainerView.frame.size.width / 6 - (CGFloat(i) * (userImagesContainerView.frame.size.width / 6 + userImagesContainerView.frame.size.width / 24))
                let userAvatarImageView = UIImageView(frame: CGRect(x: x, y: 0, width: userImagesContainerView.frame.size.width / 6, height: userImagesContainerView.frame.size.width / 6))
                userAvatarImageView.sd_setImageWithURL(NSURL(string: (pod.podUsers![i].userImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
                userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2.0
                userAvatarImageView.layer.masksToBounds = true
                userImagesContainerView.addSubview(userAvatarImageView)
            }
        }
    }
}