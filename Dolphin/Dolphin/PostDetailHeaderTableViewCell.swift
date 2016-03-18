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
        } else {
            postImageView.image = UIImage(named: "PostImagePlaceholder")
        }
        postTextView.text = post.postText
        backgroundColor = UIColor.clearColor()
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
}
