//
//  ProfileAvatarTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/28/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

protocol ProfileAvatarTableViewCellDelegate {
    func onSelectImageTouchUpInside()
}

class ProfileAvatarTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageViewProfileAvatar: UIImageView!
    @IBOutlet weak var labelChangeImage: UILabel!
    
    var delegate: ProfileAvatarTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        Utils.setFontFamilyForView(labelChangeImage, includeSubViews: true)
        let tapImageGesture = UITapGestureRecognizer(target: self, action: "selectImage:")
        imageViewProfileAvatar.addGestureRecognizer(tapImageGesture)
        imageViewProfileAvatar.userInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageViewProfileAvatar.layer.cornerRadius = imageViewProfileAvatar.frame.width / 2
        imageViewProfileAvatar.clipsToBounds = true
    }
    
    func configureWithImage(previousImageURL: String?, imageData: UIImage?, delegate: SettingsViewController) {
        self.delegate = delegate
        if imageData != nil {
            imageViewProfileAvatar.image = imageData
        } else if previousImageURL != nil {
            imageViewProfileAvatar.sd_setImageWithURL(NSURL(string: previousImageURL!), placeholderImage: UIImage(named: "UserPlaceholder"))
        } else {
            imageViewProfileAvatar.image = UIImage(named: "UserPlaceholder")
        }
    }
    
    // MARK: - Actions
    
    func selectImage(sender: AnyObject) {
        delegate?.onSelectImageTouchUpInside()
    }
    
    

    

}