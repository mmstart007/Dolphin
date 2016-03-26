//
//  CreatePostAddDescriptionTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SDWebImage

class CreatePostAddDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewPostImage: UIImageView!
    @IBOutlet weak var textFieldPostTitle: UITextField!
    @IBOutlet weak var textViewDescription: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textViewDescription.placeholder = "Write your moment..."
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithImage(isLink: Bool, postImage: UIImage?, postURL: String?, postImageURL: String?) {
        
        if isLink {
            let manager = SDWebImageManager.sharedManager()
            manager.downloadImageWithURL(NSURL(string: postImageURL!), options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    let resizedImage = Utils.resizeImage(image, newWidth: self.imageViewPostImage.frame.width)
                    let croppedImage = Utils.cropToBounds(resizedImage, width: self.imageViewPostImage.frame.width, height: self.imageViewPostImage.frame.height)
                    self.imageViewPostImage.image = croppedImage
                } else {
                    self.imageViewPostImage.image = UIImage(named: "PostImagePlaceholder")
                }
            })
        } else {
            let resizedImage = Utils.resizeImage(postImage!, newWidth: imageViewPostImage.frame.width)
            let croppedImage = Utils.cropToBounds(resizedImage, width: imageViewPostImage.frame.width, height: imageViewPostImage.frame.height)
            imageViewPostImage.image = croppedImage
        }
        if isLink {
            textFieldPostTitle.text = postURL
            textFieldPostTitle.userInteractionEnabled = false
        } else {
            textFieldPostTitle.userInteractionEnabled = true
            
        }
    }

}
