//
//  InviteFriendsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/24/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit


class InviteFriendsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var segmentedControl: HMSegmentedControl!
    var facebookFriends: [FacebookFriend] = []
    var twitterFriends: [TwitterFriend]   = []
    var tableView: UITableView!
    var signInLabel: UILabel!
    var loginFacebookTapGesture: UITapGestureRecognizer!
    var loginTwitterTapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        title = "Invite Friends"
        setBackButton()
        
        initializeSegmentedControl()
        initializeTableViewAndGestures()
        
    }
    
    func initializeSegmentedControl() {
        segmentedControl = HMSegmentedControl(sectionImages: [UIImage(named: "TopBarContactsNotSelectedIcon")!, UIImage(named: "TopBarFacebookNotSelectedIcon")!, UIImage(named: "TopBarTwitterNotSelectedIcon")!, UIImage(named: "TopBarMoreNotSelectedIcon")!], sectionSelectedImages: [UIImage(named: "TopBarContactsSelectedIcon")!, UIImage(named: "TopBarFacebookSelectedIcon")!, UIImage(named: "TopBarTwitterSelectedIcon")!, UIImage(named: "TopBarMoreSelectedIcon")!])
        
        segmentedControl.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 80)
        segmentedControl.selectionIndicatorHeight = 4.0
        segmentedControl.backgroundColor = UIColor.blueDolphin()
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedControl.selectionIndicatorColor = UIColor.whiteColor()
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()];
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor()];
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(segmentedControl)
    }
    
    func initializeTableViewAndGestures() {
        tableView = UITableView(frame: CGRect(x: 0, y: 80, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.size.height - 80), style: .Plain)
        tableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "FriendToInviteTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FriendToInviteTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        signInLabel               = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 50))
        signInLabel.textAlignment = .Center
        signInLabel.font = UIFont(name: "Raleway-Regular", size: 14)
        signInLabel.center.y      = self.tableView.center.y - 50.0
        signInLabel.hidden        = true
        signInLabel.textColor     = UIColor.blueDolphin()
        self.view.addSubview(signInLabel)
        
        loginFacebookTapGesture = UITapGestureRecognizer(target: self, action: "loginFacebookToGetFriends")
        loginTwitterTapGesture = UITapGestureRecognizer(target: self, action: "loginTwitterToGetFriends")
        tableView.addGestureRecognizer(loginFacebookTapGesture)
        tableView.addGestureRecognizer(loginTwitterTapGesture)
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled = false
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        signInLabel.hidden              = true
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled  = false
        if segmentedControl.selectedSegmentIndex == 1 {
            self.tableView.reloadData()
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                signInLabel.text = "You need to log in to Facebook to invite friends \n Tap to login"
                signInLabel.numberOfLines = 2
                signInLabel.hidden = false
                loginFacebookTapGesture.enabled = true
            } else {
                getFacebookFriendsList()
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if Twitter.sharedInstance().session() == nil {
                self.signInLabel.text = "You need to log in to Twitter to invite friends \n Tap to login"
                self.signInLabel.numberOfLines = 2
                self.signInLabel.hidden = false
                self.loginTwitterTapGesture.enabled = true
            } else {
                getTwitterFollowingList()
            }
        }
        tableView.reloadData()
    }
    
    // MARK: Social Networks login
    
    func loginTwitterToGetFriends() {
        if Twitter.sharedInstance().session() == nil {
            Twitter.sharedInstance().logInWithCompletion { session, error in
                if (session != nil) {
                    print("signed in as \(session!.userName)");
                    self.signInLabel.hidden = true
                    self.loginTwitterTapGesture.enabled = false
                    self.getTwitterFollowingList()
                } else {
                    Utils.presentAlertMessage("Error", message: "Error signing in to Twitter", cancelActionText: "Ok", presentingViewContoller: self)
                }
            }
        } else {
            getTwitterFollowingList()
        }
    }
    
    func loginFacebookToGetFriends() {
        print("login gesture")
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(["public_profile", "user_friends"], fromViewController: self, handler: { (result, error) -> Void in
                if error != nil {
                    Utils.presentAlertMessage("Error", message: "Error signing in to Facebook", cancelActionText: "Ok", presentingViewContoller: self)
                } else if !result.isCancelled {
                    self.signInLabel.hidden = true
                    self.loginFacebookTapGesture.enabled = false
                    self.getFacebookFriendsList()
                }
            })
        } else {
            getFacebookFriendsList()
        }
    }
    
    // MARK: Populate Lists
    
    func getFacebookFriendsList() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            FBSDKGraphRequest.init(graphPath: "me/taggable_friends", parameters: ["fields": "name, picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if error == nil {
                    self.facebookFriends.removeAll()
                    if let users = result["data"]!! as? [[String: AnyObject]] {
                        for friendInfo: [String: AnyObject] in users {
                            let friendModel = FacebookFriend(name: friendInfo["name"] as! String!, imageURL: friendInfo["picture"]!["data"]!!["url"] as! String!, user_id: friendInfo["id"] as! String!)
                            self.facebookFriends.append(friendModel)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func getTwitterFollowingList() {
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/friends/list.json"
            let params = ["include_user_entities": "true"]
            var clientError : NSError?
            let request = client.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    let json : NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    if let usersArray = json["users"] as? [[String: AnyObject]] {
                        self.twitterFriends.removeAll()
                        for user: [String: AnyObject!] in usersArray {
                            let twitterFriend = TwitterFriend(name: user["name"] as! String, imageURL: user["profile_image_url"] as! String, user_id: user["id_str"] as! String)
                            self.twitterFriends.append(twitterFriend)
                        }
                        self.tableView.reloadData()
                    }
                }
                else {
                    print("Error: \(connectionError)")
                }
            }
            
            
            
        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return facebookFriends.count
        } else if segmentedControl.selectedSegmentIndex == 2 {
            return twitterFriends.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
        if cell == nil {
            cell = FriendToInviteTableViewCell()
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            cell?.configureWithFacebookFriend(facebookFriends[indexPath.row])
        } else if segmentedControl.selectedSegmentIndex == 2 {
            cell?.configureWithTwitterFriend(twitterFriends[indexPath.row])
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
}
