//
//  CreatePostAddDescriptionTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SDWebImage
import KSTokenView

class CreatePostAddDescriptionTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var imageViewPostImage: UIImageView!
    @IBOutlet weak var textFieldPostTitle: UITextField!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var postTagsTextView: KSTokenView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textViewDescription.placeholder = "Write your moment..."
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithImage(isLink: Bool, postImage: UIImage?, postURL: String?, postImageURL: String?) {
        postTagsTextView.promptText       = ""
        postTagsTextView.placeholder      = ""
        postTagsTextView.maxTokenLimit    = 8//default is -1 for unlimited number of tokens
        postTagsTextView.style            = .Rounded
        postTagsTextView.searchResultSize = CGSize(width: postTagsTextView.frame.width, height: 70)
        postTagsTextView.font             = UIFont.systemFontOfSize(14)
        postTagsTextView.backgroundColor = UIColor.clearColor()
        for view in postTagsTextView.subviews {
            if view.isKindOfClass(UITextField) {
                
                let textField = view as? UITextField
                textField?.borderStyle = .None
                
            }
        }
        
        if isLink {
            let manager = SDWebImageManager.sharedManager()
            manager.downloadImageWithURL(NSURL(string: postImageURL!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    self.imageViewPostImage.image = image
                } else {
                    self.imageViewPostImage.image = UIImage(named: "PostImagePlaceholder")
                }
            })
        } else {
            imageViewPostImage.image = postImage!
        }
        if isLink {
            textFieldPostTitle.text = postURL
            textFieldPostTitle.userInteractionEnabled = false
        } else {
            textFieldPostTitle.userInteractionEnabled = true
        }
    }
}
