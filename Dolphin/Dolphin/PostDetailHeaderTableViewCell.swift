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

class PostDetailHeaderTableViewCell : UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var postLabelTitle: UILabel!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    
    var actualPost: Post?
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.userInteractionEnabled = false
        postContent.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "openWebPage")
        tapGesture.numberOfTapsRequired = 1
        postContent.addGestureRecognizer(tapGesture)
    }
    
    func configureWithPost(post: Post) {
        actualPost = post
        if post.postType?.name == "link" {
            postLabelTitle.text = post.postText
            postContent.text = post.postLink?.url

        } else {
            postLabelTitle.text = post.postHeader
            postContent.text   = post.postText
        }
        
        if actualPost != nil {
            
            //Adjust image size.
            if let image = post.postImage {
                let image_width = image.imageWidth
                let image_height = image.imageHeight
                
                adjustImageSize(image_width!, image_height: image_height!)
            }
                
                //Link Image
            else if let linkImage = post.postLink {
                let image_width = linkImage.imageWidth
                let image_height = linkImage.imageHeight
                adjustImageSize(image_width!, image_height: image_height!)
            }
            else {
                constraintHeightImageView.constant = 1
            }
            
            if let postImage = actualPost!.postImage {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postImage.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        self.postImageView.image = image
                        
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if let postLink = actualPost!.postLink {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(NSURL(string: (postLink.imageURL)!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        self.postImageView.image = image
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if actualPost?.postType?.name == "text" {
                constraintHeightImageView.constant = 0
                self.addConstraint(constraintHeightImageView)
            } else {
                postImageView.image = UIImage(named: "PostImagePlaceholder")
            }
        }
        backgroundColor = UIColor.clearColor()
    }
    
    func adjustImageSize(image_width: CGFloat, image_height: CGFloat) {
        if image_width == 0 || image_height == 0 {
            let real_width = postImageView.frame.size.width
            constraintHeightImageView.constant = real_width
        }
        else {
            let real_width = postImageView.frame.size.width
            let real_height = real_width * image_height / image_width
            constraintHeightImageView.constant = real_height
        }
    }
    
    func adjustCellViews() {

    }
 
    func openWebPage() {
        if actualPost!.postType?.name == "link" {
            let urlString = actualPost?.postLink?.url
            if(urlString != nil && urlString?.characters.count > 0)  {
                let postURL = NSURL(string: urlString!)
                if UIApplication.sharedApplication().canOpenURL(postURL!) {
                    UIApplication.sharedApplication().openURL(postURL!)
                }
            }
        }
    }
    
}
