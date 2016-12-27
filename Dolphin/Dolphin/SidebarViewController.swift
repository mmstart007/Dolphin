//
//  SidebarViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
    
class SidebarViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let networkController = NetworkController.sharedInstance
    
    // MARK: IBOutlets
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!

    var items = [["title": "My Feed", "icon": "SidebarDolphinIcon"],
                 ["title": "My Likes", "icon": "SidebarGlassesIcon"],
                 ["title": "My PODS", "icon": "SidebarMyPODsIcon"],
                 ["title": "Invite Friends", "icon": "SidebarInviteFriendsIcon"],
                 ["title": "Notifications", "icon": "notifications-button"],
                 ["title": "Dolphin Deals", "icon": "SidebarDolphinDealsIcon"],
                 ["title": "Logout", "icon": "SidebarLogoutIcon"],
                 ]
    
    var homeViewController: HomeViewController!
    
    init(homeVC: HomeViewController) {
        super.init(nibName: "SidebarViewController", bundle: nil)
        self.homeViewController = homeVC
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAppearance()
        
        self.headerView.isUserInteractionEnabled = true
        contentTableView.register(UINib(nibName: "SideTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SideTableViewCell")
        contentTableView.tableHeaderView = self.headerView
        
        let tapAvatarGesture = UITapGestureRecognizer(target: self, action: #selector(tapAvatar))
        tapAvatarGesture.numberOfTapsRequired = 1
        avatarView.addGestureRecognizer(tapAvatarGesture)
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let user = networkController.currentUser {
            let firstName = user.firstName
            let lastName = user.lastName
            if firstName != "" && lastName != "" {
                labelUserName.text = String(format: "%@ %@", user.firstName!, user.lastName!)
            } else {
                labelUserName.text = user.userName!
            }
            
            if user.userAvatarImageURL != nil {
                userImageView.sd_setImage(with: URL(string: self.convertURL(user.userAvatarImageURL!)), placeholderImage: UIImage(named: "UserPlaceholder"))
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Customize Appearance
    
    func setAppearance() {
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2.0
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.borderWidth = 3
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.layer.shouldRasterize = true
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
    }
    
    // MARK: Menu Options
    
    func myFeedButtonTouchUpInside() {
        print("My feed menu item selected")
//        setMyFeedSelected()
        revealViewController().revealToggle(animated: true)
        homeViewController.selectedIndex = 1

    }
    
    func likeButtonTouchUpInside() {
        print("History menu item selected")
        revealViewController().revealToggle(animated: true)
        homeViewController.navigationController?.pushViewController(FeedViewController(likes: true), animated: true)
    }
    
    func myPODsButtonTouchUpInside() {
        print("My PODs menu item selected")
        revealViewController().revealToggle(animated: true)
        homeViewController.selectedIndex = 4
        (homeViewController.viewControllers![4] as? PODsListViewController)?.segmentedControl.selectedSegmentIndex = 1
        (homeViewController.viewControllers![4] as? PODsListViewController)?.segmentedControlChanged(UIEvent())
    }
    
    func inviteFriendsButtonTouchUpInside() {
        print("Invite Friends menu item selected")
        revealViewController().revealToggle(animated: true)
        homeViewController.navigationController?.pushViewController(InviteFriendsViewController(), animated: true)
    }
    
    func dolphinDealsButtonTouchUpInside() {
        print("Dolphin Deals menu item selected")
        revealViewController().revealToggle(animated: true)
        homeViewController.navigationController?.pushViewController(DealsListViewController(), animated: true)
//        setDealsSelected()
    }
    
    func logoutButtonTouchUpInside() {
        print("Logout button pressed")
        revealViewController().revealToggle(animated: true)
        // remove user token
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "api_token")
        
        let loginVC = LoginViewController()
        let rootViewController = (UIApplication.shared.delegate as! AppDelegate).homeViewController
        rootViewController?.navigationController?.isNavigationBarHidden = true
        rootViewController?.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func settingsButtonTouchUpInside(_ sender: AnyObject) {
        print("Settings button pressed")
        if networkController.currentUserId == nil {
            let alert = UIAlertController(title: "Warning", message: "You need to logout and login again, sorry this is for this time because we are in development", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            revealViewController().revealToggle(animated: true)
            let settingsVC = SettingsViewController()
            homeViewController.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    func tapAvatar() {
        settingsButtonTouchUpInside(self)
    }
    
    func notificationButtonTouchUpInside() {
        print("Dolphin Deals menu item selected")
        revealViewController().revealToggle(animated: true)
        homeViewController.navigationController?.pushViewController(NotificationViewController(), animated: true)
    }
    
    // MARK - UITableview Delegate.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SideTableViewCell") as? SideTableViewCell
        if cell == nil {
            cell = SideTableViewCell()
        }
        
        let item = items[indexPath.row]
        cell?.configureCell(item["title"], icon: item["icon"])
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.myFeedButtonTouchUpInside()
        }
        else if indexPath.row == 1 {
            self.likeButtonTouchUpInside()
        }
        else if indexPath.row == 2 {
            self.myPODsButtonTouchUpInside()
        }
        else if indexPath.row == 3 {
            self.inviteFriendsButtonTouchUpInside()
        }
        else if indexPath.row == 4 {
            self.notificationButtonTouchUpInside()
        }
        else if indexPath.row == 5 {
            self.dolphinDealsButtonTouchUpInside()
        }
        else if indexPath.row == 6 {
            self.logoutButtonTouchUpInside()
        }
    }

    func convertURL(_ urlString: String) -> String {
        if urlString.contains("http") {
            return urlString
        } else {
            return Constants.RESTAPIConfig.Developement.BaseUrl + urlString
        }
    }
}
