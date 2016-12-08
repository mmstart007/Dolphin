//
//  SideTableViewCell.swift
//  Dolphin
//
//  Created by Joachim on 8/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class SideTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ title: String!, icon: String!) {
        self.titleLabel.text = title
        self.iconImageView.image = UIImage(named: icon)
    }
    
}
