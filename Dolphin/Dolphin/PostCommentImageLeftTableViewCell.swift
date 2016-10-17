//
//  PostCommentImageLeftTableViewCell.swift
//  Dolphin
//
//  Created by Mobi Soft on 10/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class PostCommentImageLeftTableViewCell : CustomFontTableViewCell {
    

    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var postCommentImage: UIImageView!
    @IBOutlet weak var postCommentLike: UIButton!
    @IBOutlet weak var postCommentUserImageView: UIImageView!
    @IBOutlet weak var postCommentTextView: UITextView!
    @IBOutlet weak var postCommentUserNameLabel: UILabel!
    @IBOutlet weak var postCommentDateLabel: UILabel!
    @IBOutlet weak var postCommentTextViewHeightConstraint: NSLayoutConstraint!
    
    var controller : UIViewController?
    let networkController = NetworkController.sharedInstance
    var mComment : PostComment?
    var mPost : Post?
    
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
    
    func configureWithPostComment(comment: PostComment) {
        self.mComment = comment
        postCommentUserImageView.sd_setImageWithURL(NSURL(string: (comment.postCommentUser?.userAvatarImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
        self.layer.cornerRadius                               = 5
        postCommentTextView.text                              = comment.postCommentText
        postCommentTextView.textContainer.lineFragmentPadding = 0
        postCommentUserNameLabel.text                         = comment.postCommentUser?.userName
        if let date = comment.postCommentDate {
            postCommentDateLabel.text = date.formattedAsTimeAgo()
        }
        postCommentUserImageView.layer.cornerRadius           = postCommentUserImageView.frame.size.width / 2.0
        postCommentUserImageView.layer.masksToBounds          = true
        postCommentTextView.textColor                         = UIColor.lightGrayColor()
        postCommentTextView.textAlignment                     = .Left
        let fixedWidth = postCommentTextView.frame.size.width
        postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newHeight = max(newSize.height, 40)
        self.postCommentTextViewHeightConstraint.constant = newHeight + 10
        Utils.setFontFamilyForView(self, includeSubViews: true)
        
        var imageUrl: String? = ""
        if(comment.postLink != nil)
        {
            imageUrl = comment.postLink?.imageURL
        }
        else{
            imageUrl = comment.postImage?.imageURL
        }
        
        if let userImageUrl = imageUrl {
            postCommentImage.sd_setImageWithURL(NSURL(string: (userImageUrl)), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            postCommentImage.image = UIImage(named: "PostImagePlaceholder")
        }
        
        self.updateLikeUI()
    }
    
    func updateLikeUI()
    {
        if (self.mComment!.postCommentIsLike == 1) {
            self.imgLike.image = UIImage(named: "ViewsGlassIcon")
        } else {
            self.imgLike.image = UIImage(named: "SunglassesIconNotLiked")
        }
    }
    
    func adjustCellViews() {
        postCommentUserImageView.layer.cornerRadius  = postCommentUserImageView.frame.size.width / 2.0
    }
    
    @IBAction func likeTapped(sender: AnyObject) {
        let postIdString = String(self.mPost!.postId!)
        let commentIdString = String(self.mComment!.postCommentId!)
        SVProgressHUD.showWithStatus("Likeing...")
        if (mComment!.postCommentIsLike == 0) {
            self.networkController.likeComment(commentIdString, podId: postIdString , completionHandler: { (liked, error) -> () in
                if error == nil {
                    
                    /*if (liked != nil) {
                     self.mComment!.postCommentIsLike = 1;
                     } else {
                     // there was an error saving the post
                     }*/
                    self.mComment!.postCommentIsLike = 1;
                    self.updateLikeUI()
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    var alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.controller!.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
        else{
            self.networkController.dislikeComment(commentIdString, podId: postIdString , completionHandler: { (liked, error) -> () in
                if error == nil {
                    
                    /*if (liked != nil) {
                     self.mComment!.postCommentIsLike = 0;
                     } else {
                     // there was an error saving the post
                     }*/
                    self.mComment!.postCommentIsLike = 0;
                    self.updateLikeUI()
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    var alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.controller!.presentViewController(alert, animated: true, completion: nil)
                }
            })
            
        }
    }
}

