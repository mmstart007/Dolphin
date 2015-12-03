//
//  PostDetailHeaderTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostDetailHeaderTableViewCell : UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    func configureWithPost(post: Post) {
        postImageView.sd_setImageWithURL(NSURL(string: (post.postImageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        postTextView.text = post.postText
        backgroundColor = UIColor.clearColor()
    }
    
}
