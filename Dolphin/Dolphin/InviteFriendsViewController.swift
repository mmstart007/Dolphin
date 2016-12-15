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
import PinterestSDK

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            getContactsFromAddressBook()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
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
        segmentedControl.selectionIndicatorLocation = .down
        segmentedControl.selectionIndicatorColor = UIColor.white
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white];
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.red];
        segmentedControl.addTarget(self, action: #selector(InviteFriendsViewController.segmentedControlChanged(_:)), for: UIControlEvents.valueChanged)
        headerView.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func initializeTableViewAndGestures() {
        tableView.register(UINib(nibName: "FriendToInviteTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "FriendToInviteTableViewCell")
        
        signInLabel               = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        signInLabel.textAlignment = .center
        signInLabel.font = UIFont(name: "Raleway-Regular", size: 14)
        signInLabel.center.y      = self.tableView.center.y - 50.0
        signInLabel.isHidden        = true
        signInLabel.textColor     = UIColor.blueDolphin()
        self.view.addSubview(signInLabel)
        
        loginFacebookTapGesture = UITapGestureRecognizer(target: self, action: #selector(InviteFriendsViewController.loginFacebookToGetFriends))
        loginTwitterTapGesture = UITapGestureRecognizer(target: self, action: #selector(InviteFriendsViewController.loginTwitterToGetFriends))
        contactsTapGesture = UITapGestureRecognizer(target: self, action: #selector(InviteFriendsViewController.openSettings))
        loginPinterestTapGesture = UITapGestureRecognizer(target: self, action: #selector(InviteFriendsViewController.loginWithPinterest))
        
        loginFacebookTapGesture.isEnabled = false
        loginTwitterTapGesture.isEnabled = false
        contactsTapGesture.isEnabled = false
        tableView.addGestureRecognizer(loginFacebookTapGesture)
        tableView.addGestureRecognizer(loginTwitterTapGesture)
        tableView.addGestureRecognizer(contactsTapGesture)
        tableView.addGestureRecognizer(loginPinterestTapGesture)
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(_ event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        signInLabel.isHidden              = true
        loginFacebookTapGesture.isEnabled = false
        loginTwitterTapGesture.isEnabled  = false
        contactsTapGesture.isEnabled      = false
        loginPinterestTapGesture.isEnabled = false
        
        if segmentedControl.selectedSegmentIndex == 0 {
            getContactsFromAddressBook()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            self.tableView.reloadData()
            if (FBSDKAccessToken.current() == nil) {
                signInLabel.text = "You need to log in to Facebook to invite friends \n Tap to login"
                signInLabel.numberOfLines = 2
                signInLabel.isHidden = false
                loginFacebookTapGesture.isEnabled = true
            } else {
                getFacebookFriendsList()
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            if Twitter.sharedInstance().sessionStore.session() != nil {
                self.signInLabel.text = "You need to log in to Twitter to invite friends \n Tap to login"
                self.signInLabel.numberOfLines = 2
                self.signInLabel.isHidden = false
                self.loginTwitterTapGesture.isEnabled = true
            } else {
                getTwitterFollowingList()
            }
        }
       else {
            if isLogginedPinterest == false {
                self.signInLabel.text = "You need to log in to Pinterest to invite friends \n Tap to login"
                self.signInLabel.numberOfLines = 2
                self.signInLabel.isHidden = false
                loginPinterestTapGesture.isEnabled = true
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
        case .denied, .restricted:
            signInLabel.text           = "Access to the address book wasn't granted. \n Please tap here to allow access and import contacts"
            signInLabel.numberOfLines = 2
            signInLabel.isHidden         = false
            contactsTapGesture.isEnabled = true
            print("Denied")
        case .authorized:
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            
            let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
            addressBookContacts.removeAll()
            for record in allContacts {
                let currentContact: ABRecord = record
                let currentContactNameTemp = ABRecordCopyCompositeName(currentContact)
                var contactName = ""
                if currentContactNameTemp != nil {
                    let nameCFString : CFString = currentContactNameTemp!.takeRetainedValue()
                    contactName = nameCFString as String
                }
                
                let currentContactid = ABRecordGetRecordID(currentContact)
                var currentContactImage: UIImage? = nil
                if ABPersonHasImageData(currentContact) {
                    if let imageData = ABPersonCopyImageDataWithFormat(currentContact, kABPersonImageFormatThumbnail)?.takeRetainedValue() {
                        currentContactImage = UIImage(data: imageData as Data)!
                    }
                }
                
                //Phone Number
                var arrPhones: [String] = []
                let phones : ABMultiValue = ABRecordCopyValue(record, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValue
                for numberIndex : CFIndex in (0 ..< ABMultiValueGetCount(phones))
                {
                    let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                    var phoneNumber : String = phoneUnmaganed!.takeUnretainedValue() as! String
                    
                    phoneNumber = phoneNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: nil)
                    //phoneNumber = phoneNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: phoneNumber.characters.indices)
                    arrPhones.append(phoneNumber)
                }
                
                //Email.
                var arrEmails: [String] = []
                let emails : ABMultiValue = ABRecordCopyValue(record, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValue
                for numberIndex : CFIndex in (0 ..< ABMultiValueGetCount(emails))
                {
                    let emailUnmaganed = ABMultiValueCopyValueAtIndex(emails, numberIndex)
                    let email : NSString = emailUnmaganed!.takeUnretainedValue() as! String as NSString
                    arrEmails.append(email as String)
                }
                
                let addressBookContact = AddressBookContact(name: contactName, image: currentContactImage, user_id: String(currentContactid), phone: arrPhones, email: arrEmails)
                addressBookContacts.append(addressBookContact)
            }
            
            //Sort Address Book.
            let sortedArray = addressBookContacts.sorted { (element1, element2) -> Bool in
                return element1.userName < element2.userName
            }
            
            addressBookContacts.removeAll()
            for item in sortedArray {
                addressBookContacts.append(item)
            }
            
            tableView.reloadData()
            print("Authorized")
        case .notDetermined:
            promptForAddressBookRequestAccess()
            print("Not Determined")
        }
        
    }
    
    func promptForAddressBookRequestAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted, error) in
            DispatchQueue.main.async {
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
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    // MARK: Social Networks login
    
    func loginTwitterToGetFriends() {
        if Twitter.sharedInstance().sessionStore.session() != nil {
            Twitter.sharedInstance().logIn { session, error in
                if (session != nil) {
                    print("signed in as \(session!.userName)");
                    self.signInLabel.isHidden = true
                    self.loginTwitterTapGesture.isEnabled = false
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
        if (FBSDKAccessToken.current() == nil) {
            let login = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile", "user_friends"], from: self, handler: { (result, error) -> Void in
                if error != nil {
                    Utils.presentAlertMessage("Error", message: "Error signing in to Facebook", cancelActionText: "Ok", presentingViewContoller: self)
                } else if !(result?.isCancelled)! {
                    self.signInLabel.isHidden = true
                    self.loginFacebookTapGesture.isEnabled = false
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
        if (FBSDKAccessToken.current() != nil) {
            
            if(facebookFriends.count == 0) {
                SVProgressHUD.show(withStatus: "Loading...")
            }
            FBSDKGraphRequest.init(graphPath: "me/taggable_friends", parameters: ["fields": "name, picture"]).start(completionHandler: { (connection, result, error) -> Void in
                
                SVProgressHUD.dismiss()
                if error == nil {
                    self.facebookFriends.removeAll()
                    if let users = (result as! [String: AnyObject])["data"]! as? [[String: AnyObject]] {
                        for friendInfo: [String: AnyObject] in users {
                            let friendModel = FacebookFriend(name: friendInfo["name"] as! String!, imageURL: (friendInfo["picture"] as! [String: AnyObject])["data"]!["url"] as! String!, user_id: friendInfo["id"] as! String!)
                            self.facebookFriends.append(friendModel)
                        }
                    }
                    
                    //Sort Facebook Friends.
                    let sortedArray = self.facebookFriends.sorted { (element1, element2) -> Bool in
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
            let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
            
            if(twitterFriends.count == 0) {
                SVProgressHUD.show(withStatus: "Loading...")
            }
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                SVProgressHUD.dismiss()
                if (connectionError == nil) {
                    let json : NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    if let usersArray = json["users"] as? [[String: AnyObject]] {
                        self.twitterFriends.removeAll()
                        for user: [String: AnyObject?] in usersArray {
                            let twitterFriend = TwitterFriend(name: user["name"] as! String, imageURL: user["profile_image_url"] as! String, user_id: user["id_str"] as! String)
                            self.twitterFriends.append(twitterFriend)
                        }
                        
                        //Sort Twitter Friends.
                        let sortedArray = self.twitterFriends.sorted { (element1, element2) -> Bool in
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
        PDKClient.sharedInstance().silentlyAuthenticate(success: { (response) in
            self.isLogginedPinterest = true
        }) { (error) in
            self.isLogginedPinterest = false
        }
    }
    
    func loginWithPinterest() {
        
        PDKClient.sharedInstance().authenticate(
            withPermissions: [PDKClientReadPublicPermissions, PDKClientWritePublicPermissions, PDKClientReadRelationshipsPermissions, PDKClientWriteRelationshipsPermissions],
                                                               withSuccess: { (response) in
                                                                
                                                                self.isLogginedPinterest = true
                                                                self.signInLabel.isHidden = true
                                                                self.getPinterestFriends()
            }) { (error) in
                print(error?.localizedDescription as Any)
        }
    }
    
    func getPinterestFriends() {
        PDKClient.sharedInstance().getAuthorizedUserFollowers(withFields: ["id", "username", "first_name", "last_name", "bio", "image"], success: { (response) in
            self.pinterestFriends.removeAll()
            let users = response?.users()
            for u in users! {
                self.pinterestFriends.append(u as! PDKUser)
            }
            self.tableView.reloadData()

            }) { (error) in
                print(error?.localizedDescription as Any)
        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
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
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // Mark: - Invite.
    func inviteFriend(_ friend: AnyObject, type: Int) {
        
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
    func inviteContactFriend(_ friend: AddressBookContact) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = self.getInviteMessage()
            controller.recipients = friend.userPhone
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: Constants.Messages.UnsupportedSMSTitle, message: Constants.Messages.UnsupportedSMS, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Facebook.
    func inviteFacebookFriend(_ friend: FacebookFriend) {
        
        let content = FBSDKAppInviteContent()
        content.appLinkURL = URL(string: Constants.iTunesURL)
        FBSDKAppInviteDialog.show(from: self, with: content, delegate: nil)
        
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
    func inviteTwitterFriend(_ friend: TwitterFriend) {
        if let session = Twitter.sharedInstance().sessionStore.session() {
            let client = TWTRAPIClient(userID: session.userID)
           
            let friend_user_id = friend.userId
            let text = self.getInviteMessage()
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/direct_messages/new.json"
            let params = ["user_id": friend_user_id, "text" : text]
            var clientError : NSError?
            let request = client.urlRequest(withMethod: "POST", url: statusesShowEndpoint, parameters: params, error: &clientError)
            
            SVProgressHUD.show(withStatus: "Sending...")
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                SVProgressHUD.dismiss()
                if (connectionError == nil) {
                    let json : NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    print("result: \(json)")
                    Utils.presentAlertMessage("Success", message: "Sent Invitation", cancelActionText: "Ok", presentingViewContoller: self)
                }
                else {
                    print("Error: \(connectionError)")
                    Utils.presentAlertMessage("Error", message: (connectionError?.localizedDescription)!, cancelActionText: "Ok", presentingViewContoller: self)
                }
            }
        }
    }
    
    //Instagram.
    func invitePinterestFriend(_ friend: PDKUser) {
        
    }
    
    // MARK: Search
    
    func searchButtonPressed() {
        isSearch = true
        
        if searchBar == nil {
            searchBar                    = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        }
        removeAllItemsFromNavBar()
        
        navigationItem.titleView     = searchBar
        searchBar?.tintColor = UIColor.white
        UITextField.my_appearanceWhenContained(within: [UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
    }
    
    func removeAllItemsFromNavBar() {
        navigationItem.rightBarButtonItems = []
        navigationItem.titleView           = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        filterContentForSearchText("")
        removeSearchBar()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
    
    func filterContentForSearchText(_ searchText: String) {
        
        //Address book.
        searchAddressBookFriends.removeAll()
        
        if searchText.characters.count == 0 {
            searchAddressBookFriends.append(contentsOf: addressBookContacts)
        } else {
            searchAddressBookFriends = addressBookContacts.filter({( user : AddressBookContact) -> Bool in
                let containInName = (user.userName?.lowercased().contains(searchText.lowercased()))!
                return containInName
            })
        }
        
        //Facebook.
        searchFacebookFriends.removeAll()
        if searchText.characters.count == 0 {
            searchFacebookFriends.append(contentsOf: facebookFriends)
        }
        else {
            searchFacebookFriends = facebookFriends.filter({( user : FacebookFriend) -> Bool in
                let containInName = (user.userName?.lowercased().contains(searchText.lowercased()))!
                return containInName
            })
        }
        
        
        //Twitter.
        searchTwitterFriends.removeAll()
        if searchText.characters.count == 0 {
            searchTwitterFriends.append(contentsOf: twitterFriends)
        }
        else {
            searchTwitterFriends = twitterFriends.filter({( user : TwitterFriend) -> Bool in
                let containInName = (user.userName?.lowercased().contains(searchText.lowercased()))!
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
        let rightButton                   = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(InviteFriendsViewController.searchButtonPressed))
        rightButton.tintColor             = UIColor.white
        navigationItem.rightBarButtonItem = rightButton;
    }
}
