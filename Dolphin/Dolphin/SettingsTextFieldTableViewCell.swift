//
//  SettingsTextFieldTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class SettingsTextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelSettingName: UILabel!
    @IBOutlet weak var textFieldValue: UITextField!
    @IBOutlet weak var layoutTextRight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureWithSetting(name: String, placeholder: String, value: String?, isEdit: Bool, subItem: Bool) {
        labelSettingName.text = name
        textFieldValue.placeholder = placeholder
        textFieldValue.enabled = isEdit
        
        if value != nil {
            textFieldValue.text = value
        }
        
        if subItem {
            self.accessoryType = .DisclosureIndicator
            self.layoutTextRight.constant = 25
        } else
        {
            self.accessoryType = .None
            self.layoutTextRight.constant = 15
        }
    }
    

}
