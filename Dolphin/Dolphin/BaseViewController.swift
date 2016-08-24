//
//  BaseViewController.swift
//  Dolphin
//
//  Created by Joachim on 8/24/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setBackButton() {
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(goBackButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setDismissButton() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(dismissButtonPressed(_:)))
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
        rightButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Constants.Fonts.Raleway_Regular, size: 14)!], forState: UIControlState.Normal)
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setLeftButtonItemWithText(text: String, target: AnyObject?, action: Selector) {
        let leftButton = UIBarButtonItem(title: text, style: .Plain, target: target, action: action)
        leftButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func addRightButtonItemWithImage(imageName: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(image: UIImage(named: imageName), style: .Plain, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItems?.append(rightButton)
    }


}
