//
//  NewPostPrivacySettingsShareToPODCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class NewPostPrivacySettingsShareToPODCell : CustomFontTableViewCell {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var podName: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedImageView.layer.cornerRadius  = selectedImageView.frame.size.width / 2
        selectedImageView.layer.masksToBounds = true
    }
    
    func configureWithPODPrivacySetting(_ setting: NewPostPrivacySettingsViewController.PODSharePrivacySetting) {
        
        if setting.selected {
            selectedImageView.backgroundColor = UIColor.clear
            selectedImageView.image           = UIImage(named: "CheckboxTickIcon")
        } else {
            selectedImageView.backgroundColor = UIColor.lightGray
            selectedImageView.image           = nil
        }
        podName.text = setting.pod!.name
    }
    
}
