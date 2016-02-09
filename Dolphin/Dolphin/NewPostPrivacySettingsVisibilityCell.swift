//
//  NewPostPrivacySettingsVisibilityCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class NewPostPrivacySettingsVisibilityCell : CustomFontTableViewCell {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var visibilityIconImageView: UIImageView!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var informativeTextLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedImageView.layer.cornerRadius  = selectedImageView.frame.size.width / 2
        selectedImageView.layer.masksToBounds = true
    }
    
    func configureWithVisibilitySetting(setting: NewPostPrivacySettingsViewController.VisibilitySetting, selected: Bool) {
        
        if selected {
            selectedImageView.backgroundColor = UIColor.clearColor()
            selectedImageView.image           = UIImage(named: "CheckboxTickIcon")
        } else {
            selectedImageView.backgroundColor = UIColor.lightGrayColor()
            selectedImageView.image           = nil
        }
        visibilityIconImageView.image      = setting.image != nil && setting.image != "" ? UIImage(named: setting.image!)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) : nil
        visibilityIconImageView.tintColor  = UIColor.darkGrayColor()
        if setting.informativeText == "" {
            informativeTextLabel.hidden = true
        } else {
            informativeTextLabel.hidden = false
        }
        visibilityLabel.text               = setting.name
        informativeTextLabel.text          = setting.informativeText
        informativeTextLabel.numberOfLines = 0
        informativeTextLabel.sizeToFit()
    }
    
}
