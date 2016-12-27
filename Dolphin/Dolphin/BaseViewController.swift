//
//  BaseViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 8/24/16.
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
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(goBackButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setDismissButton() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(dismissButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func goBackButtonPressed(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismissButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setRightSystemButtonItem(_ systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setRightButtonItemWithText(_ text: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        rightButton.tintColor = UIColor.white
        rightButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Constants.Fonts.Raleway_Regular, size: 14)!], for: UIControlState())
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setLeftButtonItemWithText(_ text: String, target: AnyObject?, action: Selector) {
        let leftButton = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        leftButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func addRightButtonItemWithImage(_ imageName: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: target, action: action)
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItems?.append(rightButton)
    }


}
