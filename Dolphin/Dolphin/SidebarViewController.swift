//
//  SidebarViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
    
class SidebarViewController : UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var myFeedIconImageView: UIImageView!
    @IBOutlet weak var historyIconImageView: UIImageView!
    @IBOutlet weak var myPODsIconImageView: UIImageView!
    @IBOutlet weak var inviteFriendsIconImageView: UIImageView!
    @IBOutlet weak var dolphinDealsIconImageView: UIImageView!
    @IBOutlet weak var myFeedMenuItemLabel: UILabel!
    @IBOutlet weak var historyMenuItemLabel: UILabel!
    @IBOutlet weak var myPODsMenuItemLabel: UILabel!
    @IBOutlet weak var inviteFriendsMenuItemLabel: UILabel!
    @IBOutlet weak var dolphinDealsMenuItemLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myFeedButtonTouchUpInside(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setAppearance()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Added to fix rendering problem with corner radius in user avatar imageview
        setAppearance()
    }
    
    // MARK: Customize Appearance
    
    func setAppearance() {
        userImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userImageView.layer.borderWidth = 3
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.layer.shouldRasterize = true
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
    }
    
    // MARK: Menu Options
    
    @IBAction func myFeedButtonTouchUpInside(sender: AnyObject) {
        print("My feed menu item selected")
        setAllItemsNotSelected()
        myFeedIconImageView.image = myFeedIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        myFeedIconImageView.tintColor = UIColor.yellowHighlightedMenuItem()
        myFeedMenuItemLabel.textColor = UIColor.yellowHighlightedMenuItem()
    }
    
    @IBAction func historyButtonTouchUpInside(sender: AnyObject) {
        print("History menu item selected")
        setAllItemsNotSelected()
        historyIconImageView.image = historyIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        historyIconImageView.tintColor = UIColor.yellowHighlightedMenuItem()
        historyMenuItemLabel.textColor = UIColor.yellowHighlightedMenuItem()
    }
    
    @IBAction func myPODsButtonTouchUpInside(sender: AnyObject) {
        print("My PODs menu item selected")
        setAllItemsNotSelected()
        myPODsIconImageView.image = myPODsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        myPODsIconImageView.tintColor = UIColor.yellowHighlightedMenuItem()
        myPODsMenuItemLabel.textColor = UIColor.yellowHighlightedMenuItem()
    }
    
    @IBAction func inviteFriendsButtonTouchUpInside(sender: AnyObject) {
        print("Invite Friends menu item selected")
        setAllItemsNotSelected()
        inviteFriendsIconImageView.image = inviteFriendsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        inviteFriendsIconImageView.tintColor = UIColor.yellowHighlightedMenuItem()
        inviteFriendsMenuItemLabel.textColor = UIColor.yellowHighlightedMenuItem()
    }
    
    @IBAction func dolphinDealsButtonTouchUpInside(sender: AnyObject) {
        print("Dolphin Deals menu item selected")
        setAllItemsNotSelected()
        dolphinDealsIconImageView.image = dolphinDealsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        dolphinDealsIconImageView.tintColor = UIColor.yellowHighlightedMenuItem()
        dolphinDealsMenuItemLabel.textColor = UIColor.yellowHighlightedMenuItem()
    }
    
    @IBAction func logoutButtonTouchUpInside(sender: AnyObject) {
        print("Logout button pressed")
    }
    
    @IBAction func settingsButtonTouchUpInside(sender: AnyObject) {
        print("Settings button pressed")
    }
    
    // Set all items non selected before setting the chosen one
    func setAllItemsNotSelected() {
            myFeedIconImageView.image = myFeedIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            myFeedIconImageView.tintColor = UIColor.whiteColor()
            myFeedMenuItemLabel.textColor = UIColor.whiteColor()

            historyIconImageView.image = historyIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            historyIconImageView.tintColor = UIColor.whiteColor()
            historyMenuItemLabel.textColor = UIColor.whiteColor()

            myPODsIconImageView.image = myPODsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            myPODsIconImageView.tintColor = UIColor.whiteColor()
            myPODsMenuItemLabel.textColor = UIColor.whiteColor()

            inviteFriendsIconImageView.image = inviteFriendsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            inviteFriendsIconImageView.tintColor = UIColor.whiteColor()
            inviteFriendsMenuItemLabel.textColor = UIColor.whiteColor()

            dolphinDealsIconImageView.image = dolphinDealsIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            dolphinDealsIconImageView.tintColor = UIColor.whiteColor()
            dolphinDealsMenuItemLabel.textColor = UIColor.whiteColor()
    }
    
}