//
//  CreatePostAddDescriptionTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SDWebImage
//import KSTokenView

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithImage(_ isLink: Bool, postImage: UIImage?, postURL: String?, postImageURL: String?) {
        postTagsTextView.promptText       = ""
        postTagsTextView.placeholder      = ""
        postTagsTextView.maxTokenLimit    = 8//default is -1 for unlimited number of tokens
        postTagsTextView.style            = .rounded
        postTagsTextView.searchResultSize = CGSize(width: postTagsTextView.frame.width, height: 70)
        postTagsTextView.font             = UIFont.systemFont(ofSize: 14)
        postTagsTextView.backgroundColor = UIColor.clear
        for view in postTagsTextView.subviews {
            if view.isKind(of: UITextField.self) {
                
                let textField = view as? UITextField
                textField?.borderStyle = .none
                
            }
        }
        
        if isLink {
            let manager = SDWebImageManager.shared()
            manager?.downloadImage(with: URL(string: postImageURL!), options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
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
            textFieldPostTitle.isUserInteractionEnabled = false
        } else {
            textFieldPostTitle.isUserInteractionEnabled = true
        }
    }
}
