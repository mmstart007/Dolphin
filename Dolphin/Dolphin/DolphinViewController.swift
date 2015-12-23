//
//  DolphinViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DolphinViewController : DolphinCustomFontViewController {
 
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func setRightButtonItemWithText(text: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(title: text, style: .Plain, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func addRightButtonItemWithImage(imageName: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(image: UIImage(named: imageName), style: .Plain, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItems?.append(rightButton)
    }
    
}
