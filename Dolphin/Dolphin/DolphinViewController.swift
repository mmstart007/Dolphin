//
//  DolphinViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DolphinViewController : UIViewController {
 
    func setBackButton() {
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.Plain, target: self, action:"goBackButtonPressed:")
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func goBackButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setRightSystemButtonItem(systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
    }
    
}
