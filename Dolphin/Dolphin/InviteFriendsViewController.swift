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
import FBSDKLoginKit
import FBSDKShareKit
import MessageUI
import SVProgressHUD

class InviteFriendsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, FriendToInviteTableViewCellDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    var segmentedControl: HMSegmentedControl!
    var facebookFriends: [FacebookFriend]         = []
    var twitterFriends: [TwitterFriend]           = []
    var addressBookContacts: [AddressBookContact] = []
    var instagramFriends: [InstagramFriend]       = []
    
    var signInLabel: UILabel!
    var loginFacebookTapGesture: UITapGestureRecognizer!
    var loginTwitterTapGesture: UITapGestureRecognizer!
    var contactsTapGesture: UITapGestureRecognizer!
//    var loginInstagramTapGesture: UITapGestureRecognizer!
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
    
    override func viewDidLayoutSubviews() {
        segmentedControl.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height)
    }
    
    func initializeSegmentedControl() {
        
        segmentedControl = HMSegmentedControl(sectionImages: [UIImage(named: "TopBarContactsNotSelectedIcon")!, UIImage(named: "TopBarFacebookNotSelectedIcon")!, UIImage(named: "TopBarTwitterNotSelectedIcon")!/*, UIImage(named: "TopBarMoreNotSelectedIcon")!*/], sectionSelectedImages: [UIImage(named: "TopBarContactsSelectedIcon")!, UIImage(named: "TopBarFacebookSelectedIcon")!, UIImage(named: "TopBarTwitterSelectedIcon")!/*, UIImage(named: "TopBarMoreSelectedIcon")!*/])
        
        segmentedControl.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height)
        segmentedControl.selectionIndicatorHeight = 4.0
        segmentedControl.backgroundColor = UIColor.blueDolphin()
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedControl.selectionIndicatorColor = UIColor.whiteColor()
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()];
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor()];
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        headerView.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func initializeTableViewAndGestures() {
        tableView.registerNib(UINib(nibName: "FriendToInviteTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FriendToInviteTableViewCell")
        
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
//        loginInstagramTapGesture = UITapGestureRecognizer(target: self, action: "loginInstagramToGetFriends")
        
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled = false
        contactsTapGesture.enabled = false
        tableView.addGestureRecognizer(loginFacebookTapGesture)
        tableView.addGestureRecognizer(loginTwitterTapGesture)
        tableView.addGestureRecognizer(contactsTapGesture)
//        tableView.addGestureRecognizer(loginInstagramTapGesture)
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        signInLabel.hidden              = true
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled  = false
        contactsTapGesture.enabled      = false
//        loginInstagramTapGesture.enabled = false
        
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
        }
//       else {
//            let token = currentInstagramAccessToken()
//            if token == nil {
//                self.signInLabel.text = "You need to log in to Instagram to invite friends \n Tap to login"
//                self.signInLabel.numberOfLines = 2
//                self.signInLabel.hidden = false
//                loginInstagramTapGesture.enabled = true
//            } else {
//                getInstagramFriends(token!)
//            }
//        }
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
                    let nameCFString : CFString = currentContactNameTemp.takeRetainedValue()
                    contactName = nameCFString as String
                }
                
                let currentContactid = ABRecordGetRecordID(currentContact)
                var currentContactImage: UIImage? = nil
                if ABPersonHasImageData(currentContact) {
                    if let imageData = ABPersonCopyImageDataWithFormat(currentContact, kABPersonImageFormatThumbnail)?.takeRetainedValue() {
                        currentContactImage = UIImage(data: imageData)!
                    }
                }
                
                //Phone Number
                var arrPhones: [String] = []
                let phones : ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
                for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(phones); numberIndex++)
                {
                    let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                    var phoneNumber : String = phoneUnmaganed.takeUnretainedValue() as! String
                    phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(
                        "\\D", withString: "", options: .RegularExpressionSearch,
                        range: phoneNumber.startIndex..<phoneNumber.endIndex)
                    arrPhones.append(phoneNumber)
                }
                
                //Email.
                var arrEmails: [String] = []
                let emails : ABMultiValueRef = ABRecordCopyValue(record, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
                for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(emails); numberIndex++)
                {
                    let emailUnmaganed = ABMultiValueCopyValueAtIndex(emails, numberIndex)
                    let email : NSString = emailUnmaganed.takeUnretainedValue() as! String
                    arrEmails.append(email as String)
                }
                
                let addressBookContact = AddressBookContact(name: contactName, image: currentContactImage, user_id: String(currentContactid), phone: arrPhones, email: arrEmails)
                addressBookContacts.append(addressBookContact)
            }
            
            //Sort Address Book.
            let sortedArray = addressBookContacts.sort { (element1, element2) -> Bool in
                return element1.userName < element2.userName
            }
            
            addressBookContacts.removeAll()
            for item in sortedArray {
                addressBookContacts.append(item)
            }
            
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
    
    func loginInstagramToGetFriends() {
        let token = currentInstagramAccessToken()
        if (token == nil) {
            getInstagramFollowing()
        } else {
            getInstagramFriends(token!)
        }
    }
    
    // MARK: Populate Lists
    
    func getFacebookFriendsList() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            if(facebookFriends.count == 0) {
                SVProgressHUD.showWithStatus("Loading...")
            }
            FBSDKGraphRequest.init(graphPath: "me/taggable_friends", parameters: ["fields": "name, picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                
                SVProgressHUD.dismiss()
                if error == nil {
                    self.facebookFriends.removeAll()
                    if let users = result["data"]!! as? [[String: AnyObject]] {
                        for friendInfo: [String: AnyObject] in users {
                            let friendModel = FacebookFriend(name: friendInfo["name"] as! String!, imageURL: friendInfo["picture"]!["data"]!!["url"] as! String!, user_id: friendInfo["id"] as! String!)
                            self.facebookFriends.append(friendModel)
                        }
                    }
                    
                    
                    //Sort Facebook Friends.
                    let sortedArray = self.facebookFriends.sort { (element1, element2) -> Bool in
                        return element1.userName < element2.userName
                    }
                    
                    self.facebookFriends.removeAll()
                    for item in sortedArray {
                        self.facebookFriends.append(item)
                    }
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func getTwitterFollowingList() {
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/followers/list.json"
            let params = ["include_user_entities": "true", "count" : "200"]
            var clientError : NSError?
            let request = client.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            if(twitterFriends.count == 0) {
                SVProgressHUD.showWithStatus("Loading...")
            }
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                SVProgressHUD.dismiss()
                if (connectionError == nil) {
                    let json : NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    if let usersArray = json["users"] as? [[String: AnyObject]] {
                        self.twitterFriends.removeAll()
                        for user: [String: AnyObject!] in usersArray {
                            let twitterFriend = TwitterFriend(name: user["name"] as! String, imageURL: user["profile_image_url"] as! String, user_id: user["id_str"] as! String)
                            self.twitterFriends.append(twitterFriend)
                        }
                        
                        //Sort Twitter Friends.
                        let sortedArray = self.twitterFriends.sort { (element1, element2) -> Bool in
                            return element1.userName < element2.userName
                        }
                        
                        self.twitterFriends.removeAll()
                        for item in sortedArray {
                            self.twitterFriends.append(item)
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
    
    
    func currentInstagramAccessToken() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let instagram_token = defaults.objectForKey("instagram_token") as! String?
        return instagram_token
    }
    
    func getInstagramFollowing() {
        let oauthswift = OAuth2Swift(
            consumerKey:    "cd8e8c8636da4dc58eeed535887e0de9",
            consumerSecret: "f711d56cda5e4d9481541b1aa714139a",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        
//        let oauthswift = OAuth2Swift(
//            consumerKey:    "fde55c84ca954b0298629f484bc954af",
//            consumerSecret: "10ff4ce05dc74dd8875801fa2012ce1a",
//            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
//            responseType:   "token"
//        )
        
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "oauth-swift://oauth-callback/instagram")!,
            scope: "follower_list", state:"INSTAGRAM",
            success: { credential, response, parameters in
                print(credential.oauth_token)
                
                //Save access token.
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(credential.oauth_token, forKey: "instagram_token")
                defaults.synchronize()
                
                self.signInLabel.hidden = true
//                self.loginInstagramTapGesture.enabled = false
                self.getInstagramFriends(oauthswift.client.credential.oauth_token)
                
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
    }
    
    func getInstagramFriends(token: String) {
        
        let oauthswift = OAuth2Swift(
            consumerKey:    "cd8e8c8636da4dc58eeed535887e0de9",
            consumerSecret: "f711d56cda5e4d9481541b1aa714139a",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        
//        let oauthswift = OAuth2Swift(
//            consumerKey:    "fde55c84ca954b0298629f484bc954af",
//            consumerSecret: "10ff4ce05dc74dd8875801fa2012ce1a",
//            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
//            responseType:   "token"
//        )
        
        let url :String = "https://api.instagram.com/v1/users/self/follows?access_token=\(token)"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        oauthswift.client.get(url, parameters: parameters,
            success: {
                data, response in
                
                //Parse
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
        
        cell?.delegate = self
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // Mark: - Invite.
    func inviteFriend(friend: AnyObject, type: Int) {
        
        switch type {
        case Constants.InviteType.Invite_Contact:
            self.inviteContactFriend(friend as! AddressBookContact)
            break;
            
        case Constants.InviteType.Invite_Facebook:
            self.inviteFacebookFriend(friend as! FacebookFriend)
            break;
            
        case Constants.InviteType.Invite_Twitter:
            self.inviteTwitterFriend(friend as! TwitterFriend)
            break;
            
        case Constants.InviteType.Invite_Instagram:
            break;
            
        default:
            break;
        }
    }
    
    func getInviteMessage()-> String {
        return "Check out this app" + Constants.iTunesURL
    }
    
    
    //Contact.
    func inviteContactFriend(friend: AddressBookContact) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = self.getInviteMessage()
            controller.recipients = friend.userPhone
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: Constants.Messages.UnsupportedSMSTitle, message: Constants.Messages.UnsupportedSMS, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Facebook.
    func inviteFacebookFriend(friend: FacebookFriend) {
        
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: Constants.iTunesURL)
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: nil)
        
        /*
        content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
        //optionally set previewImageURL
        content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
        
        // Present the dialog. Assumes self is a view controller
        // which implements the protocol `FBSDKAppInviteDialogDelegate`.
        [FBSDKAppInviteDialog showFromViewController:self
        withContent:content
        delegate:self];
        */
    }
    
    //Twitter.
    func inviteTwitterFriend(friend: TwitterFriend) {
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            
            let friend_user_id = friend.userId
            let text = self.getInviteMessage()
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/direct_messages/new.json"
            let params = ["user_id": friend_user_id, "text" : text]
            var clientError : NSError?
            let request = client.URLRequestWithMethod("POST", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            SVProgressHUD.showWithStatus("Sending...")
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                SVProgressHUD.dismiss()
                if (connectionError == nil) {
                    let json : NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    print("result: \(json)")
                    Utils.presentAlertMessage("Success", message: "Sent Invitation", cancelActionText: "Ok", presentingViewContoller: self)
                }
                else {
                    print("Error: \(connectionError)")
                    Utils.presentAlertMessage("Error", message: (connectionError?.description)!, cancelActionText: "Ok", presentingViewContoller: self)
                }
            }
        }
    }
    
    //Instagram.
    func inviteInstagramFriend(friend: InstagramFriend) {
        
    }
}
