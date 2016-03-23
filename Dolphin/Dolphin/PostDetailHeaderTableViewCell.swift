//
//  PostDetailHeaderTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostDetailHeaderTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    func configureWithPost(post: Post) {
        if let postImage = post.postImage {
            postImageView.sd_setImageWithURL(NSURL(string: (postImage.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        } else if let postLink = post.postLink {
            postImageView.sd_setImageWithURL(NSURL(string: (postLink.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        } else {
            postImageView.image = UIImage(named: "PostImagePlaceholder")
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
