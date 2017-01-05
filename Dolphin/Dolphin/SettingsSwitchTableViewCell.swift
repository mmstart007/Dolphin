//
//  SettingsSwitchTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

protocol SettingsSwitchTableViewCellDelegate {
    func toggleSwitch(_ enabled: Bool, tag: Int)
}

class SettingsSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var labelSettingName: UILabel!
    @IBOutlet weak var switchSetting: UISwitch!
    
    var delegate:SettingsSwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithSetting(_ name: String, delegate: SettingsSwitchTableViewCellDelegate?, tag: Int, enable: Bool) {
        self.tag = tag
        self.delegate = delegate
        labelSettingName.text = name
        switchSetting.isOn = enable
        //Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
    // MARK: - Actions
    
    @IBAction func switchSettingValueChanged(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.toggleSwitch(switchSetting.isOn, tag: self.tag)
        }
    }

}
