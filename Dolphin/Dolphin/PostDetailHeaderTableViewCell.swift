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
    
    var actualPost: Post?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func configureWithPost(post: Post) {
        actualPost = post
        if actualPost != nil {
            if let postImage = actualPost!.postImage {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postImage.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        let resizedImage = Utils.resizeImage(image, newWidth: self.postImageView.frame.width)
                        let croppedImage = Utils.cropToBounds(resizedImage, width: self.postImageView.frame.width, height: self.postImageView.frame.height)
                        self.postImageView.image = croppedImage
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if let postLink = actualPost!.postLink {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postLink.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        let resizedImage = Utils.resizeImage(image, newWidth: self.postImageView.frame.width)
                        let croppedImage = Utils.cropToBounds(resizedImage, width: self.postImageView.frame.width, height: self.postImageView.frame.height)
                        self.postImageView.image = croppedImage
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else {
                postImageView.image = UIImage(named: "PostImagePlaceholder")
            }
        }
        if post.postType?.name == "link" {
            postTextView.text = post.postLink?.url
        } else {
            postTextView.text = post.postText
        }
        backgroundColor = UIColor.clearColor()
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}
