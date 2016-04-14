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
import AddressBook
import OAuthSwift
import HMSegmentedControl


class InviteFriendsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var segmentedControl: HMSegmentedControl!
    var facebookFriends: [FacebookFriend]         = []
    var twitterFriends: [TwitterFriend]           = []
    var addressBookContacts: [AddressBookContact] = []
    var instagramFriends: [InstagramFriend]       = []
    var tableView: UITableView!
    var signInLabel: UILabel!
    var loginFacebookTapGesture: UITapGestureRecognizer!
    var loginTwitterTapGesture: UITapGestureRecognizer!
    var contactsTapGesture: UITapGestureRecognizer!
    var addressBookRef: ABAddressBook?
    
    convenience init() {
        self.init(nibName: "InviteFriendsViewController", bundle: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            getContactsFromAddressBook()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        title = "Invite Friends"
        setBackButton()
        
        initializeSegmentedControl()
        initializeTableViewAndGestures()
        getContactsFromAddressBook()
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
        segmentedControl.selectedSegmentIndex = 0
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
        contactsTapGesture = UITapGestureRecognizer(target: self, action: "openSettings")
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled = false
        contactsTapGesture.enabled = false
        tableView.addGestureRecognizer(loginFacebookTapGesture)
        tableView.addGestureRecognizer(loginTwitterTapGesture)
        tableView.addGestureRecognizer(contactsTapGesture)
        
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        signInLabel.hidden              = true
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled  = false
        contactsTapGesture.enabled      = false
        if segmentedControl.selectedSegmentIndex == 0 {
            getContactsFromAddressBook()
        } else if segmentedControl.selectedSegmentIndex == 1 {
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
        } else {
//            getInstagramFollowing()
        }
        tableView.reloadData()
    }
    
    // MARK: Address Book
    
    func getContactsFromAddressBook() {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .Denied, .Restricted:
            signInLabel.text           = "Access to the address book wasn't granted. \n Please tap here to allow access and import contacts"
            signInLabel.numberOfLines = 2
            signInLabel.hidden         = false
            contactsTapGesture.enabled = true
            print("Denied")
        case .Authorized:
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            
            let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
            addressBookContacts.removeAll()
            for record in allContacts {
                let currentContact: ABRecordRef = record
                let currentContactNameTemp = ABRecordCopyCompositeName(currentContact)
                var contactName = ""
                if currentContactNameTemp != nil {
                    if let currentContactName = currentContactNameTemp.takeRetainedValue() as? String {
                        contactName = currentContactName
                    }
                }
                
                let currentContactid = ABRecordGetRecordID(currentContact)
                var currentContactImage: UIImage? = nil
                if ABPersonHasImageData(currentContact) {
                    if let imageData = ABPersonCopyImageDataWithFormat(currentContact, kABPersonImageFormatThumbnail)?.takeRetainedValue() {
                        currentContactImage = UIImage(data: imageData)!
                    }
                }
                let addressBookContact = AddressBookContact(name: contactName, image: currentContactImage, user_id: String(currentContactid))
                addressBookContacts.append(addressBookContact)
            }
            addressBookContacts = addressBookContacts.sort({ $0.userName < $1.userName })
            tableView.reloadData()
            print("Authorized")
        case .NotDetermined:
            promptForAddressBookRequestAccess()
            print("Not Determined")
        }
        
    }
    
    func promptForAddressBookRequestAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.getContactsFromAddressBook()
                    print("Just denied")
                } else {
                    self.getContactsFromAddressBook()
                    print("Just authorized")
                }
            }
        }
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
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
            let params = ["include_user_entities": "true", "count" : "200"]
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
    
    
    
    func getInstagramFollowing() {
        let oauthswift = OAuth2Swift(
            consumerKey:    "cd8e8c8636da4dc58eeed535887e0de9",
            consumerSecret: "f711d56cda5e4d9481541b1aa714139a",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "oauth-swift://oauth-callback/instagram")!,
            scope: "follower_list", state:"INSTAGRAM",
            success: { credential, response, parameters in
                print(credential.oauth_token)
                let url :String = "https://api.instagram.com/v1/users/self/follows?access_token=\(oauthswift.client.credential.oauth_token)"
                let parameters :Dictionary = Dictionary<String, AnyObject>()
                oauthswift.client.get(url, parameters: parameters,
                    success: {
                        data, response in
                        if let jsonDict = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                            let usersDict = jsonDict?.objectForKey("data") as! NSArray
                            self.instagramFriends.removeAll()
                            for (var i = 0; i < usersDict.count; i++) {
                                if let userDict = usersDict[i] as? NSDictionary {
                                    let user = InstagramFriend(name: userDict["full_name"] as! String, imageURL: userDict["profile_picture"] as! String, user_id: userDict["id"] as! String)
                                    self.instagramFriends.append(user)
                                }
                            }
                            self.tableView.reloadData()
                        }
                    }, failure: { error in
                        print(error)
                })
                
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return addressBookContacts.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return facebookFriends.count
        } else if segmentedControl.selectedSegmentIndex == 2 {
            return twitterFriends.count
        } else {
            return instagramFriends.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
        if cell == nil {
            cell = FriendToInviteTableViewCell()
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            cell?.configureWithAddressBookContact(addressBookContacts[indexPath.row])
        } else if segmentedControl.selectedSegmentIndex == 1 {
            cell?.configureWithFacebookFriend(facebookFriends[indexPath.row])
        } else if segmentedControl.selectedSegmentIndex == 2 {
            cell?.configureWithTwitterFriend(twitterFriends[indexPath.row])
        } else {
            cell?.configureWithInstagramFriend(instagramFriends[indexPath.row])
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
}
