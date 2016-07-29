//
//  PODPreviewTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODPreviewTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var podNameLabel: UILabel!
    @IBOutlet weak var podLastPostDateLabel: UILabel!
    @IBOutlet weak var podUsersContainerView: UIView!
    @IBOutlet weak var podImageHeight: NSLayoutConstraint!
    
    var pod: POD?
    var triangleView: TriangleView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Set round border only top.
        let path = UIBezierPath(roundedRect:containerView.bounds, byRoundingCorners:[.TopRight, .TopLeft], cornerRadii: CGSizeMake(5, 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        containerView.layer.mask = maskLayer
        
        if pod != nil {
            if pod!.isPrivate == 1 {
                if triangleView == nil {
                    triangleView        = TriangleView()
                }
                triangleView!.frame = CGRect(x: self.containerView.frame.size.width - 60, y: 0, width: 60, height: 60)
                triangleView?.hidden             = false
                triangleView!.color              = pod!.podColor()
                triangleView!.backgroundColor    = UIColor.clearColor()
                triangleView!.layer.cornerRadius = 5
                self.containerView.addSubview(triangleView!)
                triangleView!.addImage("PrivatePODIcon")
            } else {
                if triangleView != nil {
                    triangleView?.hidden = true
                }
            }
            
            //Adjust Image Size,
            let image_width = self.pod!.image_width
            let image_height = self.pod!.image_height
            
            adjustImageSize(CGFloat(image_width!), image_height: CGFloat(image_height!))
        }
    }
    
    func configureWithPOD(pod: POD) {
        self.backgroundColor = UIColor.clearColor()

        containerView.layer.cornerRadius = 5
        
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSizeZero
        containerView.layer.shadowRadius = 3

        self.pod = pod
        podImageView.sd_setImageWithURL(NSURL(string: (pod.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        podImageView.contentMode = .ScaleAspectFill
        podImageView.layer.masksToBounds = true
        podNameLabel.text                = pod.name
        if let lastPostDate = pod.lastPostDate {
            podLastPostDateLabel.text    = lastPostDate.formattedAsTimeAgo()
        } else {
            podLastPostDateLabel.text    = "No posts yet"
        }
        
        //Adjust Image Size,
        let image_width = self.pod!.image_width
        let image_height = self.pod!.image_height
        
        adjustImageSize(CGFloat(image_width!), image_height: CGFloat(image_height!))
    }
    
    func adjustImageSize(image_width: CGFloat, image_height: CGFloat) {
        if image_width == 0 || image_height == 0 {
            podImageHeight.constant = 130.0
        }
        else {
            let real_width = podImageView.frame.size.width
            let real_height = real_width * image_height / image_width
            podImageHeight.constant = real_height
        }
    }
    
    func addUserImages(pod: POD) {
        for userView in podUsersContainerView.subviews {
            userView.removeFromSuperview()
        }
        if pod.isPrivate != nil && pod.isPrivate! == 0 {
            for (var i = 0; (i < pod.users?.count && i < 5); i=i+1) {
                if i == 0 && pod.users?.count > 5 {
                    // Add Label that shows number of remaining users in POD
                    let x: CGFloat = podUsersContainerView.frame.size.width - podUsersContainerView.frame.size.width / 6 - (CGFloat(i) * (podUsersContainerView.frame.size.width / 6 + podUsersContainerView.frame.size.width / 24))
                    let otherUsersLabel = UILabel(frame: CGRect(x: x, y: 0, width: podUsersContainerView.frame.size.width / 6, height: podUsersContainerView.frame.size.width / 6))
                    otherUsersLabel.backgroundColor = UIColor.lightGrayColor()
                    otherUsersLabel.textColor = UIColor.lightTextColor()
                    otherUsersLabel.layer.cornerRadius = otherUsersLabel.frame.size.width / 2.0
                    otherUsersLabel.layer.masksToBounds = true
                    otherUsersLabel.text = String(format: "+%li", arguments: [(pod.users?.count)! - 4])
                    otherUsersLabel.textAlignment = .Center
                    otherUsersLabel.font = UIFont.systemFontOfSize(12)
                    podUsersContainerView.addSubview(otherUsersLabel)
                } else {
                    // Sow image of user in POD
                    let x: CGFloat = podUsersContainerView.frame.size.width - podUsersContainerView.frame.size.width / 6 - (CGFloat(i) * (podUsersContainerView.frame.size.width / 6 + podUsersContainerView.frame.size.width / 24))
                    let userAvatarImageView = UIImageView(frame: CGRect(x: x, y: 0, width: podUsersContainerView.frame.size.width / 6, height: podUsersContainerView.frame.size.width / 6))
                    userAvatarImageView.sd_setImageWithURL(NSURL(string: (pod.users![i].userAvatarImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
                    userAvatarImageView.layer.cornerRadius  = userAvatarImageView.frame.size.width / 2.0
                    userAvatarImageView.layer.masksToBounds = true
                    userAvatarImageView.contentMode         = .ScaleAspectFill
                    podUsersContainerView.addSubview(userAvatarImageView)
                }
            }
        }
    }
    
}
