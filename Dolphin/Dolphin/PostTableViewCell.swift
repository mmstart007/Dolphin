//
//  PostTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postuserImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var linkTypePostContainer: UIView!
    @IBOutlet weak var linkPostTitleLabel: UILabel!
    @IBOutlet weak var linkPostURLLabel: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet var linkInfoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var postNumberOfLikesWidthConstarint: NSLayoutConstraint!
    @IBOutlet var postNumberOfCommentsWidthConstraint: NSLayoutConstraint!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    var cellPost: Post?
    var triangleView: TriangleView?
    
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
        if let post = cellPost {
            
            postuserImageView.layer.cornerRadius = postuserImageView.frame.size.width / 2.0
            if triangleView == nil {
                triangleView        = TriangleView()
                triangleView!.frame = CGRect(x: self.frame.size.width - 30, y: 0, width: 30, height: 30)
            }
            triangleView!.color           = post.postColor()
            triangleView!.backgroundColor = UIColor.clearColor()
            self.addSubview(triangleView!)
        }
    }
    
    func configureWithPost(post: Post) {
        self.cellPost = post
        
        postImageView.sd_setImageWithURL(NSURL(string: (post.postImageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
        postuserImageView.sd_setImageWithURL(NSURL(string: (post.postUser?.userImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
        postText.text = post.postText
        self.layer.cornerRadius               = 5
        postImageView.layer.cornerRadius      = 5
        postImageView.layer.masksToBounds     = true
        postuserImageView.layer.cornerRadius  = postuserImageView.frame.size.width / 2.0
        postuserImageView.layer.masksToBounds = true
        
        postUserNameLabel.text                = String(format: "Posted by %@", arguments: [(post.postUser?.userName)!])
        postDateLabel.text                    = post.postDate?.timeAgo()
        numberOfLikesLabel.text               = String(format: "%li", arguments: [post.postNumberOfLikes!])
        numberOfCommentsLabel.text            = String(format: "%li", arguments: [post.postNumberOfComments!])

        layoutIfNeeded()

        let fixedWidth = postText.frame.size.width
        postText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = postText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        self.textHeightConstraint.constant = newSize.height

        if post.isLikedByUser {
            likedImageView.image = UIImage(named: "ViewsGlassIcon")
        } else {
            likedImageView.image = UIImage(named: "SunglassesIconNotLiked")
        }
        
        let attributedStringLikes = NSAttributedString(string: String(post.postNumberOfLikes!), attributes: [NSFontAttributeName:numberOfLikesLabel.font])
        let sizeLikes = attributedStringLikes.boundingRectWithSize(CGSize(width: 1000, height: 20), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        postNumberOfLikesWidthConstarint.constant = sizeLikes.width + 5
        numberOfLikesLabel.text = String(post.postNumberOfLikes!)
        
        let attributedStringComments = NSAttributedString(string: String(post.postNumberOfComments!), attributes: [NSFontAttributeName:numberOfCommentsLabel.font])
        let sizeComments = attributedStringComments.boundingRectWithSize(CGSize(width: 1000, height: 20), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        postNumberOfCommentsWidthConstraint.constant = sizeComments.width + 5
        numberOfCommentsLabel.text = String(post.postNumberOfComments!)
        
        if post.postType == .URL {
            linkPostTitleLabel.text                    = post.postText
            linkPostURLLabel.text                      = post.postHeader
            linkInfoContainerHeightConstraint.active   = true
            linkInfoContainerHeightConstraint.constant = 50
            linkTypePostContainer.hidden               = false
            postImageView.hidden                       = false
            postImageViewHeightConstraint.active       = false
            self.textHeightConstraint.active           = false
        } else if post.postType == .Text {
            postImageView.hidden                     = true
            self.textHeightConstraint.active         = true
            linkInfoContainerHeightConstraint.active = false
            linkTypePostContainer.hidden             = true
            postImageViewHeightConstraint.active     = true
            postImageViewHeightConstraint.constant   = 0
        } else {
            self.textHeightConstraint.active         = true
            linkInfoContainerHeightConstraint.active = false
            linkTypePostContainer.hidden             = true
            postImageView.hidden                     = false
            postImageViewHeightConstraint.active     = false
        }
    }
    
}
