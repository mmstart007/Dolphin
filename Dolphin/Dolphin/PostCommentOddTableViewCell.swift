//
//  PostCommentTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostCommentOddTableViewCell : CustomFontTableViewCell {
    
    @IBOutlet weak var postCommentUserImageView: UIImageView!
    @IBOutlet weak var postCommentTextView: UITextView!
    @IBOutlet weak var postCommentUserNameLabel: UILabel!
    @IBOutlet weak var postCommentDateLabel: UILabel!
    @IBOutlet weak var postCommentTextViewHeightConstraint: NSLayoutConstraint!
    
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
        self.layer.cornerRadius               = 5
        postCommentUserImageView.sd_setImageWithURL(NSURL(string: (comment.postCommentUser?.userAvatarImageURL)!), placeholderImage: UIImage(named: "UserPlaceholder"))
        postCommentTextView.text                              = comment.postCommentText
        postCommentTextView.textContainer.lineFragmentPadding = 0
        postCommentUserNameLabel.text                         = comment.postCommentUser?.userName
        if let date = comment.postCommentDate {
            postCommentDateLabel.text = date.formattedAsTimeAgo()
        }
        postCommentUserImageView.layer.cornerRadius           = postCommentUserImageView.frame.size.width / 2.0
        postCommentUserImageView.layer.masksToBounds          = true
        postCommentTextView.textColor                         = UIColor.lightGrayColor()
        let fixedWidth                                        = postCommentTextView.frame.size.width
        postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = postCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newHeight = max(newSize.height, 40)
        self.postCommentTextViewHeightConstraint.constant = newHeight + 10
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
    func adjustCellViews() {
        postCommentUserImageView.layer.cornerRadius  = postCommentUserImageView.frame.size.width / 2.0
    }
    
}
