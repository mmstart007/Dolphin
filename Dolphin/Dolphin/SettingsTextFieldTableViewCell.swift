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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureWithSetting(name: String, placeholder: String) {
        labelSettingName.text = name
        textFieldValue.placeholder = placeholder
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    

}
