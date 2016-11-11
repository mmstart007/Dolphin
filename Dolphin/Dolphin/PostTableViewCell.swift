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

@objc protocol PostTableViewCellDelegate {
    optional func tapURL(url: String?)
    optional func tapLike(post: Post?, cell: PostTableViewCell?)
    optional func downloadedPostImage(indexPath: NSIndexPath?)
    optional func tapUserInfo(userInfo: User?)
}

class PostTableViewCell : UITableViewCell {
    
    var delegate:PostTableViewCellDelegate?

    @IBOutlet weak var containerView: UIView!
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
        
        containerView.layer.cornerRadius      = 5

        postuserImageView.layer.cornerRadius  = postuserImageView.frame.size.width / 2.0
        postuserImageView.layer.masksToBounds = true
        postuserImageView.userInteractionEnabled = true
        
        let tapGestureLike = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.actionLike))
        tapGestureLike.numberOfTapsRequired = 1
        likedImageView.addGestureRecognizer(tapGestureLike)
        
        let tapGestureURL = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.actionURL))
        tapGestureURL.numberOfTapsRequired = 1
        postContent.addGestureRecognizer(tapGestureURL)
        
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSizeZero
        containerView.layer.shadowRadius = 3
        
        if triangleView == nil {
            triangleView        = TriangleView()
            let xPosition       = containerView.frame.size.width - 30
            triangleView!.frame = CGRect(x: xPosition, y: 0, width: 30, height: 30)
            triangleView!.backgroundColor = UIColor.clearColor()
            containerView.addSubview(triangleView!)
        }
        
        self.backgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.didTapUser))
        postuserImageView.addGestureRecognizer(tapGesture)
        
        let tapGestureUsername = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.didTapUser))
        postUserNameLabel.addGestureRecognizer(tapGestureUsername)
    }
    
    func didTapUser() {
        self.delegate?.tapUserInfo!(cellPost?.postUser)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xPosition       = containerView.frame.size.width - 30
        triangleView!.frame = CGRect(x: xPosition, y: 0, width: 30, height: 30)
        
        //Set round border only top.
        let path = UIBezierPath(roundedRect:containerView.bounds, byRoundingCorners:[.TopRight, .TopLeft], cornerRadii: CGSizeMake(5, 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        containerView.layer.mask = maskLayer
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
        
        triangleView!.color           = cellPost!.postColor()
        
        //Adjust image size.
        if let image = post.postImage {
            postTitle.text = post.postHeader
            postContent.text = ""
            self.postImageView.sd_setImageWithURL(NSURL(string: (image.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            let image_width = image.imageWidth
            let image_height = image.imageHeight
            
            adjustImageSize(image_width!, image_height: image_height!)
        }

        //Link Image
        else if let linkImage = post.postLink {
            postTitle.text = post.postText
            postContent.text = post.postLink?.url
            self.postImageView.sd_setImageWithURL(NSURL(string: (linkImage.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            
            let image_width = linkImage.imageWidth
            let image_height = linkImage.imageHeight
            adjustImageSize(image_width!, image_height: image_height!)
        }
        else {
            postTitle.text = post.postHeader
            postContent.text = post.postText
            postImageViewHeightConstraint.constant = 0
        }

        layoutIfNeeded()
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
