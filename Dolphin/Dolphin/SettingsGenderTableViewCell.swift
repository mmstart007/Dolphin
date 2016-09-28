//
//  SettingsGenderTableViewCell.swift
//  Dolphin
//
//  Created by Joachim on 8/24/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit


protocol SettingsGenderTableViewCellDelegate {
    func changedGender(gender: Int)
}

class SettingsGenderTableViewCell: UITableViewCell {
    @IBOutlet weak var genderSegement: UISegmentedControl!
    var delegate:SettingsGenderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithSetting(delegate: SettingsGenderTableViewCellDelegate?, gender: Int!) {
        self.delegate = delegate
        self.genderSegement.selectedSegmentIndex = gender
    }
    
    @IBAction func switchSettingValueChanged(sender: AnyObject) {
        if delegate != nil {
            delegate?.changedGender(self.genderSegement.selectedSegmentIndex)
        }
    }
}