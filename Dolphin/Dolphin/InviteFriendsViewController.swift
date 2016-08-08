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

class InviteFriendsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, FriendToInviteTableViewCellDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    var searchBar: UISearchBar?

    var segmentedControl: HMSegmentedControl!
    var facebookFriends: [FacebookFriend]               = []
    var searchFacebookFriends: [FacebookFriend]         = []
    
    var twitterFriends: [TwitterFriend]                 = []
    var searchTwitterFriends: [TwitterFriend]           = []
    
    var addressBookContacts: [AddressBookContact]       = []
    var searchAddressBookFriends: [AddressBookContact]  = []
    
    var pinterestFriends: [PDKUser]                     = []
    var searchPinterestFriends: [PDKUser]               = []
    var isLogginedPinterest: Bool                       = false
    
    var signInLabel: UILabel!
    var loginFacebookTapGesture: UITapGestureRecognizer!
    var loginTwitterTapGesture: UITapGestureRecognizer!
    var contactsTapGesture: UITapGestureRecognizer!
    var loginPinterestTapGesture: UITapGestureRecognizer!
    var addressBookRef: ABAddressBook?
    
    var isSearch: Bool = false
    
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
        setSearchRightButton()
        
        initializeSegmentedControl()
        initializeTableViewAndGestures()
        getContactsFromAddressBook()
        checkPinterestToken()
    }
    
    override func viewDidLayoutSubviews() {
        segmentedControl.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height)
    }
    
    func initializeSegmentedControl() {
        
        segmentedControl = HMSegmentedControl(sectionImages: [UIImage(named: "TopBarContactsNotSelectedIcon")!, UIImage(named: "TopBarFacebookNotSelectedIcon")!, UIImage(named: "TopBarTwitterNotSelectedIcon")!, UIImage(named: "pinterestIconNotSelected")!], sectionSelectedImages: [UIImage(named: "TopBarContactsSelectedIcon")!, UIImage(named: "TopBarFacebookSelectedIcon")!, UIImage(named: "TopBarTwitterSelectedIcon")!, UIImage(named: "pinterestIcon")!])
        
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
        loginPinterestTapGesture = UITapGestureRecognizer(target: self, action: "loginWithPinterest")
        
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled = false
        contactsTapGesture.enabled = false
        tableView.addGestureRecognizer(loginFacebookTapGesture)
        tableView.addGestureRecognizer(loginTwitterTapGesture)
        tableView.addGestureRecognizer(contactsTapGesture)
        tableView.addGestureRecognizer(loginPinterestTapGesture)
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        signInLabel.hidden              = true
        loginFacebookTapGesture.enabled = false
        loginTwitterTapGesture.enabled  = false
        contactsTapGesture.enabled      = false
        loginPinterestTapGesture.enabled = false
        
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
            if let session = Twitter.sharedInstance().sessionStore.session() {
                self.signInLabel.text = "You need to log in to Twitter to invite friends \n Tap to login"
                self.signInLabel.numberOfLines = 2
                self.signInLabel.hidden = false
                self.loginTwitterTapGesture.enabled = true
            } else {
                getTwitterFollowingList()
            }
        }
       else {
            if isLogginedPinterest == false {
                self.signInLabel.text = "You need to log in to Pinterest to invite friends \n Tap to login"
                self.signInLabel.numberOfLines = 2
                self.signInLabel.hidden = false
                loginPinterestTapGesture.enabled = true
            } else {
                self.getPinterestFriends()
            }
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
        if let session = Twitter.sharedInstance().sessionStore.session() {
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
    
    func loginPinterestToGetFriends() {
        if (self.isLogginedPinterest == false) {
            loginWithPinterest()
        } else {
            getPinterestFriends()
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
        if let session = Twitter.sharedInstance().sessionStore.session() {
            let client = TWTRAPIClient(userID: session.userID)
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
    
    // MARK: Pinterest.
    
    func checkPinterestToken() {
        PDKClient.sharedInstance().silentlyAuthenticateWithSuccess({ (response) in
            self.isLogginedPinterest = true
        }) { (error) in
            self.isLogginedPinterest = false
        }
    }
    
    func loginWithPinterest() {
        
        PDKClient.sharedInstance().authenticateWithPermissions(
            [PDKClientReadPublicPermissions, PDKClientWritePublicPermissions, PDKClientReadRelationshipsPermissions, PDKClientWriteRelationshipsPermissions],
                                                               withSuccess: { (response) in
                                                                
                                                                self.isLogginedPinterest = true
                                                                self.signInLabel.hidden = true
                                                                self.getPinterestFriends()
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func getPinterestFriends() {
        PDKClient.sharedInstance().getAuthorizedUserFollowersWithFields(["id", "username", "first_name", "last_name", "bio", "image"], success: { (response) in
            self.pinterestFriends.removeAll()
            let users = response.users()
            for u in users {
                self.pinterestFriends.append(u as! PDKUser)
            }
            self.tableView.reloadData()

            }) { (error) in
                print(error)
        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            if isSearch {
                return searchAddressBookFriends.count
            } else {
                return addressBookContacts.count
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if isSearch {
                return searchFacebookFriends.count
            } else {
                return facebookFriends.count
            }
            
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if isSearch {
                return searchTwitterFriends.count
            } else {
                return twitterFriends.count
            }
        } else {
            if isSearch {
                return searchPinterestFriends.count
            } else {
                return pinterestFriends.count
            }
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
        if cell == nil {
            cell = FriendToInviteTableViewCell()
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            if self.isSearch {
                cell?.configureWithAddressBookContact(searchAddressBookFriends[indexPath.row])
            }
            else {
                cell?.configureWithAddressBookContact(addressBookContacts[indexPath.row])
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if self.isSearch {
                cell?.configureWithFacebookFriend(searchFacebookFriends[indexPath.row])
            }
            else {
                cell?.configureWithFacebookFriend(facebookFriends[indexPath.row])
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if self.isSearch {
                cell?.configureWithTwitterFriend(searchTwitterFriends[indexPath.row])
            }
            else {
                cell?.configureWithTwitterFriend(twitterFriends[indexPath.row])
            }
        } else {
            if self.isSearch {
                cell?.configureWithPinterestFriend(searchPinterestFriends[indexPath.row])
            }
            else {
                cell?.configureWithPinterestFriend(pinterestFriends[indexPath.row])
            }
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
        if let session = Twitter.sharedInstance().sessionStore.session() {
            let client = TWTRAPIClient(userID: session.userID)
           
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
    func invitePinterestFriend(friend: PDKUser) {
        
    }
    
    // MARK: Search
    
    func searchButtonPressed() {
        isSearch = true
        
        if searchBar == nil {
            searchBar                    = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 40))
        }
        removeAllItemsFromNavBar()
        
        navigationItem.titleView     = searchBar
        searchBar?.tintColor = UIColor.whiteColor()
        UITextField.my_appearanceWhenContainedWithin([UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
    }
    
    func removeAllItemsFromNavBar() {
        navigationItem.rightBarButtonItems = []
        navigationItem.titleView           = nil
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearch = false
        filterContentForSearchText("")
        removeSearchBar()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        isSearch = false
        searchBar.resignFirstResponder()
    }
    
    func removeSearchBar() {
        removeAllItemsFromNavBar()
        searchBar?.text = ""
        title = "Invite "
        searchBar?.resignFirstResponder()
        setSearchRightButton()
    }
    
    func filterContentForSearchText(searchText: String) {
        
        //Address book.
        searchAddressBookFriends.removeAll()
        
        if searchText.characters.count == 0 {
            searchAddressBookFriends.appendContentsOf(addressBookContacts)
        } else {
            searchAddressBookFriends = addressBookContacts.filter({( user : AddressBookContact) -> Bool in
                let containInName = (user.userName?.lowercaseString.containsString(searchText.lowercaseString))!
                return containInName
            })
        }
        
        //Facebook.
        searchFacebookFriends.removeAll()
        if searchText.characters.count == 0 {
            searchFacebookFriends.appendContentsOf(facebookFriends)
        }
        else {
            searchFacebookFriends = facebookFriends.filter({( user : FacebookFriend) -> Bool in
                let containInName = (user.userName?.lowercaseString.containsString(searchText.lowercaseString))!
                return containInName
            })
        }
        
        
        //Twitter.
        searchTwitterFriends.removeAll()
        if searchText.characters.count == 0 {
            searchTwitterFriends.appendContentsOf(twitterFriends)
        }
        else {
            searchTwitterFriends = twitterFriends.filter({( user : TwitterFriend) -> Bool in
                let containInName = (user.userName?.lowercaseString.containsString(searchText.lowercaseString))!
                return containInName
            })
        }

        self.tableView.reloadData()
    }
    
    func hideSearchField() {
        isSearch = false
        self.searchBar?.resignFirstResponder()
    }

    func setSearchRightButton()  {
        let rightButton                   = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonPressed")
        rightButton.tintColor             = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
    }
}
