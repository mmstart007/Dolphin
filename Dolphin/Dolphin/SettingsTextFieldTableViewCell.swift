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

    
    func configureWithSetting(_ name: String, placeholder: String, value: String?, isEdit: Bool, subItem: Bool) {
        labelSettingName.text = name
        textFieldValue.placeholder = placeholder
        textFieldValue.isEnabled = isEdit
        
        if value != nil {
            textFieldValue.text = value
        }
        
        if subItem {
            self.accessoryType = .disclosureIndicator
            self.layoutTextRight.constant = 0
        } else
        {
            self.accessoryType = .none
            self.layoutTextRight.constant = 15
        }
    }
    

}
