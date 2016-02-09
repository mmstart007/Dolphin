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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "resignResponder")
//        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackButton() {
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.Plain, target: self, action:"goBackButtonPressed:")
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setDismissButton() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissButtonPressed:")
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func goBackButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func resignResponder() {
        if let firstResponder = view.findViewThatIsFirstResponder() {
            firstResponder.resignFirstResponder()
        }
    }
    
}
