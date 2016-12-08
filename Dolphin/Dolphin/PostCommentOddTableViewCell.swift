//
//  PostCommentTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class PostCommentOddTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var imgLiked: UIImageView!
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
    
    func configureWithPostComment(_ comment: PostComment) {
        self.mComment = comment
        self.layer.cornerRadius               = 5
        postCommentUserImageView.sd_setImage(with: URL(string: (comment.postCommentUser?.userAvatarImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
        postCommentTextView.text                              = comment.postCommentText
        postCommentTextView.textContainer.lineFragmentPadding = 0
        postCommentUserNameLabel.text                         = comment.postCommentUser?.userName
        if let date = comment.postCommentDate {
            postCommentDateLabel.text = date.formattedAsTimeAgo()
        }
        postCommentUserImageView.layer.cornerRadius           = postCommentUserImageView.frame.size.width / 2.0
        postCommentUserImageView.layer.masksToBounds          = true
        postCommentTextView.textColor                         = UIColor.lightGray
        let fixedWidth                                        = postCommentTextView.frame.size.width
        postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = max(newSize.height, 40)
        self.postCommentTextViewHeightConstraint.constant = newHeight + 10
        Utils.setFontFamilyForView(self, includeSubViews: true)
        
        self.updateLikeUI()
    }
    
    func updateLikeUI()
    {
        if (self.mComment!.postCommentIsLike == 1) {
            self.imgLiked.image = UIImage(named: "ViewsGlassIcon")
        } else {
            self.imgLiked.image = UIImage(named: "SunglassesIconNotLiked")
        }
    }
    
    func adjustCellViews() {
        postCommentUserImageView.layer.cornerRadius  = postCommentUserImageView.frame.size.width / 2.0
    }
    
    @IBAction func likeTapped(_ sender: AnyObject) {
        let postIdString = String(self.mPost!.postId!)
        let commentIdString = String(self.mComment!.postCommentId!)
        SVProgressHUD.show(withStatus: "Likeing...")
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
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.controller!.present(alert, animated: true, completion: nil)
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
                        alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.controller!.present(alert, animated: true, completion: nil)
                }
            })

        }
    }
    
    
    
}
