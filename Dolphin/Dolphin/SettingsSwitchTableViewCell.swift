//
//  SettingsSwitchTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

protocol SettingsSwitchTableViewCellDelegate {
    func toggleSwitch(enabled: Bool, tag: Int)
}

class SettingsSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var labelSettingName: UILabel!
    @IBOutlet weak var switchSetting: UISwitch!
    
    var delegate:SettingsSwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithSetting(name: String, delegate: SettingsSwitchTableViewCellDelegate?, tag: Int) {
        self.tag = tag
        self.delegate = delegate
        labelSettingName.text = name
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }
    
    // MARK: - Actions
    
    @IBAction func switchSettingValueChanged(sender: AnyObject) {
        if delegate != nil {
            delegate?.toggleSwitch(switchSetting.on, tag: self.tag)
        }
    }
    

}
