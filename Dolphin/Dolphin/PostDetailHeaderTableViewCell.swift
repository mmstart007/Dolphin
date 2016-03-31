//
//  PostDetailHeaderTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class PostDetailHeaderTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postLabelTitle: UILabel!
    @IBOutlet weak var constraintHeightContainer: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightTextView: NSLayoutConstraint!
    var actualPost: Post?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureWithPost(post: Post) {
        actualPost = post
        
        
        if post.postType?.name == "link" {
            postLabelTitle.text = post.postText
            postTextView.text = post.postLink?.url
        } else {
            postLabelTitle.text = post.postHeader
            postTextView.text   = post.postText
        }
        postTextView.textColor = UIColor.lightGrayColor()
        if actualPost != nil {
            if let postImage = actualPost!.postImage {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postImage.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        let resizedImage = Utils.resizeImage(image, newWidth: self.postImageView.frame.width)
                        self.postImageView.image = resizedImage
                        let calculatedHeight = self.calculateHeight()
                        self.constraintHeightContainer.constant = self.postImageView.image!.size.height + self.postLabelTitle.frame.size.height + calculatedHeight
                        
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if let postLink = actualPost!.postLink {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postLink.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        let resizedImage = Utils.resizeImage(image, newWidth: self.postImageView.frame.width)
                        self.postImageView.image = resizedImage
                        let calculatedHeight = self.calculateHeight()
                        self.constraintHeightContainer.constant = self.postImageView.image!.size.height + self.postLabelTitle.frame.size.height + calculatedHeight
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if actualPost?.postType?.name == "text" {
                let calculatedHeight = self.calculateHeight()
                // remove the image using this constraint
                constraintHeightImageView.constant = 0
                self.addConstraint(constraintHeightImageView)
                constraintHeightContainer.constant = self.postLabelTitle.frame.size.height + calculatedHeight
            } else {
                postImageView.image = UIImage(named: "PostImagePlaceholder")
            }
        }
        backgroundColor = UIColor.clearColor()
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
    func adjustCellViews() {

    }
    
    func calculateHeight() -> CGFloat {
        let fixedWidth = postTextView.frame.size.width
        postTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = postTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        return newSize.height
    }
    
}
