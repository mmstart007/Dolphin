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
        edgesForExtendedLayout = UIRectEdge()
    }
    
    func setMenuLeftButton() {
        
        let leftButton                   = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: UIBarButtonItemStyle.plain, target: self.revealViewController(), action:#selector(SWRevealViewController.revealToggle(_:)))
        leftButton.tintColor             = UIColor.white
        navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setSearchRightButton() {
        
        let rightButton                   = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: Selector(("searchButtonPressed")))
        rightButton.tintColor             = UIColor.white
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
