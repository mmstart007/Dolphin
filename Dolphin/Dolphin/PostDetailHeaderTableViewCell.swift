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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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

        self.contentView.isUserInteractionEnabled = false
        postContent.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostDetailHeaderTableViewCell.openWebPage))
        tapGesture.numberOfTapsRequired = 1
        postContent.addGestureRecognizer(tapGesture)
    }
    
    func configureWithPost(_ post: Post) {
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
                let manager = SDWebImageManager.shared()
                
                let urlString = convertURL(postImage.imageURL!)
                
                manager?.downloadImage(with: URL(string: urlString), options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                    if error == nil {
                        self.postImageView.image = image
                        
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else if let postLink = actualPost!.postLink {
                let manager = SDWebImageManager.shared()
                
                let urlString = convertURL(postLink.imageURL!)
                
                manager?.downloadImage(with: URL(string: urlString), options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
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
        backgroundColor = UIColor.clear
    }
    
    func adjustImageSize(_ image_width: CGFloat, image_height: CGFloat) {
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
                let postURL = URL(string: urlString!)
                if UIApplication.shared.canOpenURL(postURL!) {
                    UIApplication.shared.openURL(postURL!)
                }
            }
        }
    }
    
    func convertURL(_ urlString: String) -> String {
        if urlString.contains("http") {
            return urlString
        } else {
            return Constants.RESTAPIConfig.Developement.BaseUrl + urlString
        }
    }
}
