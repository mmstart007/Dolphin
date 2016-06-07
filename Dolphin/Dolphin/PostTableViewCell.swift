//
//  PostTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import NSDate_TimeAgo

@objc protocol PostTableViewCellDelegate{
    optional func tapURL(url: String?)
    optional func tapLike(post: Post?, cell: PostTableViewCell?)
    optional func downloadedPostImage(indexPath: NSIndexPath?)
}

class PostTableViewCell : UITableViewCell {
    
    var delegate:PostTableViewCellDelegate?

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var postuserImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    var cellPost: Post?
    var cellIndexPath: NSIndexPath?
    var triangleView: TriangleView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.userInteractionEnabled = false
        
        self.layer.cornerRadius               = 5
        postImageView.layer.cornerRadius      = 5
        postImageView.layer.masksToBounds     = true
        postuserImageView.layer.cornerRadius  = postuserImageView.frame.size.width / 2.0
        postuserImageView.layer.masksToBounds = true

        let tapGestureLike = UITapGestureRecognizer(target: self, action: "actionLike")
        tapGestureLike.numberOfTapsRequired = 1
        likedImageView.addGestureRecognizer(tapGestureLike)
        
        let tapGestureURL = UITapGestureRecognizer(target: self, action: "actionURL")
        tapGestureURL.numberOfTapsRequired = 1
        postContent.addGestureRecognizer(tapGestureURL)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func adjustImageSize(image_width: CGFloat, image_height: CGFloat) {
        if image_width == 0 || image_height == 0 {
            let real_width = postImageView.frame.size.width
            postImageViewHeightConstraint.constant = real_width
        }
        else {
            let real_width = postImageView.frame.size.width
            let real_height = real_width * image_height / image_width
            postImageViewHeightConstraint.constant = real_height
        }
    }
    
    func configureWithPost(post: Post) {
        configureWithPost(post, indexPath: self.cellIndexPath!)
    }
    
    func configureWithPost(post: Post, indexPath: NSIndexPath) {
        self.cellPost = post
        self.cellIndexPath = indexPath
        
        if let userImageUrl = post.postUser?.userAvatarImageURL {
            postuserImageView.sd_setImageWithURL(NSURL(string: (userImageUrl)), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            postuserImageView.image = UIImage(named: "PostImagePlaceholder")
        }
        
        postUserNameLabel.text                = String(format: "Posted by %@", arguments: [(post.postUser?.userName)!])
        if let date = post.postDate {
            postDateLabel.text                = date.formattedAsTimeAgo()
        }
        numberOfLikesLabel.text = String(post.postNumberOfLikes!)
        numberOfCommentsLabel.text = String(post.postNumberOfComments!)

        if post.isLikedByUser {
            likedImageView.image = UIImage(named: "ViewsGlassIcon")
        } else {
            likedImageView.image = UIImage(named: "SunglassesIconNotLiked")
        }
        
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
            postImageViewHeightConstraint.constant = 1
        }
        
        adjustImages()
        if post.postType?.name == "link" {
            postTitle.text = post.postText
            postContent.text = post.postLink?.url
        } else if post.postType?.name == "text" {
            postTitle.text = post.postHeader
            postContent.text = post.postText
        } else {
            postTitle.text = post.postHeader
            postContent.text = ""
        }
        
        layoutIfNeeded()
    }
    
    func adjustImages() {
        if let post = cellPost {
            if let image = post.postImage {
                
                self.postImageView.sd_setImageWithURL(NSURL(string: (image.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"), completed: { (image, error, SDImageCacheType, imageUrl) -> Void in
                    if error == nil {
                        self.postImageView.image = image
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
                
            } else if let linkImage = post.postLink {
                
                self.postImageView.sd_setImageWithURL(NSURL(string: (linkImage.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"), completed: { (image, error, SDImageCacheType, imageUrl) -> Void in
                    if error == nil {
                        self.postImageView.image = image
                    } else {
                        self.postImageView.image = UIImage(named: "PostImagePlaceholder")
                    }
                })
            } else {
                postImageView.image = UIImage(named: "PostImagePlaceholder")
            }
        }
    }
    
    
    func adjustViews() {
        if triangleView == nil {
            triangleView        = TriangleView()
            let xPosition       = self.frame.size.width - 30
            triangleView!.frame = CGRect(x: xPosition, y: 0, width: 30, height: 30)
            triangleView!.color           = cellPost!.postColor()
            triangleView!.backgroundColor = UIColor.clearColor()
            self.addSubview(triangleView!)
        }
    }
    
    func actionLike() {
        self.delegate?.tapLike!(self.cellPost, cell: self)
    }
    
    func actionURL() {
        if self.cellPost?.postType?.name == "link" {
            let url = self.cellPost?.postLink?.url
            if(url != nil && url?.characters.count > 0)  {
                self.delegate?.tapURL!(url!)
            }
        }
    }
}
