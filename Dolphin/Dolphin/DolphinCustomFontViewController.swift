//
//  DolphinCustomFontViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/23/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DolphinCustomFontViewController : UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
    }
    
}