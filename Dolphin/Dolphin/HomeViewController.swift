//
//  HomeViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : DolphinTabBarViewController {
    
    var actionMenu: UIView? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "HomeViewController", bundle: nil)
    }
    
    @IBOutlet weak var actionMenuBackground: UIView!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().enabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dolphin"
        setMenuLeftButton()
        setSearchRightButton()
        setupTabbarController()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Disable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().enabled = false
    }
    
    // MARK: Appearance and Initialization
    
    func setupTabbarController() {
        // Set appearance of TabBar
        UITabBar.appearance().barTintColor = UIColor.blueDolphin()
        UITabBar.appearance().tintColor = UIColor.redColor()
        UITabBar.appearance().selectedImageTintColor = UIColor.yellowHighlightedMenuItem()
        tabBarController?.tabBar.tintColor = UIColor.redColor()
        
        let controller1 = FeedViewController(likes: false)
        let controller2 = FeedViewController(likes: false)
        let controller3 = UIViewController()
        let controller4 = PopularViewController()
        let controller5 = PODsListViewController()
        
        controller1.tabBarItem = UITabBarItem(title: "Latest", image: UIImage(named: "TabbarLatestIcon"), selectedImage: UIImage(named: "TabbarLatestIcon"))
        controller2.tabBarItem = UITabBarItem(title: "My Feed", image: UIImage(named: "SidebarDolphinIcon"), selectedImage: UIImage(named: "SidebarDolphinIcon"))
        controller3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: ""), selectedImage: UIImage(named: ""))
        controller4.tabBarItem = UITabBarItem(title: "Popular", image: UIImage(named: "SidebarGlassesIcon"), selectedImage: UIImage(named: "SidebarGlassesIcon"))
        controller5.tabBarItem = UITabBarItem(title: "PODs", image: UIImage(named: "SidebarMyPODsIcon"), selectedImage: UIImage(named: "SidebarMyPODsIcon"))

        let tabViewControllers = [controller1, controller2, controller3, controller4, controller5]
        viewControllers = tabViewControllers
        
        // Add plus button
        let plusButton = UIButton(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width / 2.0) - 40, y: UIScreen.mainScreen().bounds.size.height - 130, width: 80, height: 80))
        plusButton.enabled = true
        plusButton.layer.cornerRadius = 40
        plusButton.layer.borderColor = UIColor.whiteColor().CGColor
        plusButton.layer.borderWidth = 3
        plusButton.setImage(UIImage(named: "TabbarPlusIcon"), forState: .Normal)
        plusButton .addTarget(self , action: "plusButtonTouchUpInside", forControlEvents: .TouchUpInside)
        plusButton.backgroundColor = UIColor.blueDolphin()
        self.view.addSubview(plusButton)
    }
    
    // MARK: Plus button Actions
    
    func plusButtonTouchUpInside() {
        print("Plus button pressed")
        let subViewsArray = NSBundle.mainBundle().loadNibNamed("NewPostMenu", owner: self, options: nil)
        self.actionMenu = subViewsArray[0] as? UIView
        actionMenuBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "actionMenuBackgroundTapped"))
        self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
        UIApplication.sharedApplication().keyWindow?.addSubview(actionMenu!)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenu?.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenuBackground.alpha = 0.4
                })
        }
    }
    
    @IBAction func closeNewPostViewButtonTouchUpInside(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenuBackground.alpha = 0
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
                    }) { (finished) -> Void in
                        self.actionMenu?.removeFromSuperview()
                }
        }
    }
    
    @IBAction func postLinkButtonTouchUpInside(sender: AnyObject) {
        let createLinkPostVC = CreateURLPostViewController()
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post link button pressed")
        
    }
    @IBAction func postPhotoButtonTouchUpInside(sender: AnyObject) {
        
        let createImagePostVC = CreateImagePostViewController()
        navigationController?.pushViewController(createImagePostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post photo button pressed")
        
    }
    @IBAction func postTextButtonTouchUpInside(sender: AnyObject) {
        
        print("Post text button pressed")
        
    }
    
    func actionMenuBackgroundTapped() {
        // Overlay was tapped, so we close the new post view
        closeNewPostViewButtonTouchUpInside(self)
    }
}