//
//  SubjectOrGradeTableViewCell.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import BEMCheckBox

class SubjectOrGradeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWithGradeOrSubjectName(name: String, checked: Bool) {
        labelName.text = name
        checkBox.on = checked
        Utils.setFontFamilyForView(self, includeSubViews: true)
    }

}
