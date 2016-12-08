//
//  SettingsGenderTableViewCell.swift
//  Dolphin
//
//  Created by Joachim on 8/24/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit


protocol SettingsGenderTableViewCellDelegate {
    func changedGender(_ gender: Int)
}

class SettingsGenderTableViewCell: UITableViewCell {
    @IBOutlet weak var genderSegement: UISegmentedControl!
    var delegate:SettingsGenderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithSetting(_ delegate: SettingsGenderTableViewCellDelegate?, gender: Int!) {
        self.delegate = delegate
        self.genderSegement.selectedSegmentIndex = gender
    }
    
    @IBAction func switchSettingValueChanged(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.changedGender(self.genderSegement.selectedSegmentIndex)
        }
    }
}
