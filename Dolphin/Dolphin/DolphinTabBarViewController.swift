//
//  DolphinViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class DolphinTabBarViewController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
        edgesForExtendedLayout = .None
    }
    
    func setMenuLeftButton() {
        
        let leftButton                   = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: UIBarButtonItemStyle.Plain, target: self.revealViewController(), action:"revealToggle:")
        leftButton.tintColor             = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setSearchRightButton() {
        
        let rightButton                   = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonPressed")
        rightButton.tintColor             = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
        
    }
    
    func removeRightButton() {
        
        navigationItem.rightBarButtonItems = []
        
    }
    
    func removeAllItemsFromNavBar() {
        navigationItem.rightBarButtonItems = []
        navigationItem.titleView           = nil
    }
    
}
