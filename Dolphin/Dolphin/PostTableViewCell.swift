//
//  PostTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostTableViewCell : UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postuserImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    
    
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
    
    func configureWithPost(post: Post) {
        postImageView.sd_setImageWithURL(NSURL(string: (post.postImageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        postuserImageView.sd_setImageWithURL(NSURL(string: (post.postUser?.userImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
        self.layer.cornerRadius               = 5
        postImageView.layer.cornerRadius      = 5
        postImageView.layer.masksToBounds     = true
        postuserImageView.layer.cornerRadius  = postuserImageView.frame.size.width / 2.0
        postuserImageView.layer.masksToBounds = true
        postText.text                         = post.postText
        postUserNameLabel.text                = String(format: "Posted by %@", arguments: [(post.postUser?.userName)!])
        postDateLabel.text                    = post.postDate?.timeAgo()
        numberOfViewsLabel.text               = String(format: "%li", arguments: [post.postNumberOfViews!])
        numberOfCommentsLabel.text            = String(format: "%li", arguments: [post.postNumberOfComments!])
    }
    
    func adjustCellViews(post: Post) {
        postuserImageView.layer.cornerRadius = postuserImageView.frame.size.width / 2.0
        let triangleView                     = TriangleView()
        triangleView.frame                   = CGRect(x: self.frame.size.width - 30, y: 0, width: 30, height: 30)
        triangleView.color                   = post.postColor()
        triangleView.backgroundColor         = UIColor.clearColor()
        self.addSubview(triangleView)
    }
    
}