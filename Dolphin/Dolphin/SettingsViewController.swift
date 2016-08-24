//
//  SettingsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/7/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
import RSKImageCropper
import SDWebImage
import MessageUI

class SettingsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource, SettingsSwitchTableViewCellDelegate,
    RSKImageCropViewControllerDelegate, ProfileAvatarTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PickerGradesOrSubjectsDelegate, MFMailComposeViewControllerDelegate, SettingsGenderTableViewCellDelegate{
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 10
    let picker = UIImagePickerController()
    let titles = ["PROFILE", "PUSH NOTIFICATIONS", "MY PODS", "DOLPHIN", "SUPPORT"]
    let dolphinItems = ["Like us on Facebook", "Follow us on Instagram", "Follow us on Twitter", "Rate our app"]
    let supportItems = ["Frequently Asked Questions", "Email Support", "Terms of Use", "Privacy Policy"]

    @IBOutlet weak var tableViewSettings: UITableView!
    
    var myPODS: [POD]       = []
    var publicProfile: Bool = false
    var page: Int           = 0
    
    var selectedGrades: [Grade]     = []
    var selectedSubjects: [Subject]   = []
    
    required init() {
        super.init(nibName: "SettingsViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        setBackButton()
        setRightButtonItemWithText("Save", target: self, action: #selector(saveSettingsPressed(_:)))
        tableViewSettings.delegate = self
        tableViewSettings.dataSource = self
        registerCells()
        
        // reset image data from the user
        networkController.currentUser?.userAvatarImageData = nil
        
        selectedGrades = (networkController.currentUser?.grades)!
        selectedSubjects = (networkController.currentUser?.subjects)!
        
        loadData()
    }
    
    func refreshView() {
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewSettings.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            // profile
            if let user = networkController.currentUser {
                if user.isPrivate == 0 {
                    return 8
                } else {
                    return 2
                }
            } else {
                return 2
            }
        case 2:
            // push notifications
            return 1
        case 3:
            // my pods
            return myPODS.count
        case 4:
            // dolphin
            return dolphinItems.count
        case 5:
            // support
            return supportItems.count
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let defaultCellIdentifier = "Cell"
        let value1CellIdentifier = "Cell1"

        if indexPath.section == 0 {
            // profile avatar cell
            cell = tableView.dequeueReusableCellWithIdentifier("ProfileAvatarTableViewCell") as? ProfileAvatarTableViewCell
            if cell == nil {
                cell = ProfileAvatarTableViewCell()
            }
            (cell as? ProfileAvatarTableViewCell)?.configureWithImage(networkController.currentUser?.userAvatarImageURL, imageData: networkController.currentUser?.userAvatarImageData, delegate: self)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // username cell
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                if cell == nil {
                    cell = SettingsTextFieldTableViewCell()
                }
                (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Username", placeholder: "username", value: networkController.currentUser?.userName, isEdit: true, subItem: false)
            }
            else {
                if indexPath.row == 1 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsSwitchTableViewCell") as? SettingsSwitchTableViewCell
                    if cell == nil {
                        cell = SettingsSwitchTableViewCell()
                    }
                    (cell as? SettingsSwitchTableViewCell)?.configureWithSetting("Private/Public", delegate: self, tag: 0, enable: networkController.currentUser?.isPrivate == 0)
                    
                } else if indexPath.row == 2 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("First Name", placeholder: "enter your name", value: networkController.currentUser?.firstName, isEdit: true, subItem: false)
                    
                } else if indexPath.row == 3 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Last Name", placeholder: "enter your last name", value: networkController.currentUser?.lastName, isEdit: true, subItem: false)
                }
                
                //Gender
                else if indexPath.row == 4 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsGenderTableViewCell") as? SettingsGenderTableViewCell
                    if cell == nil {
                        cell = SettingsGenderTableViewCell()
                    }
                    (cell as? SettingsGenderTableViewCell)?.configureWithSetting(self, gender: networkController.currentUser?.gender)
                    
                } else if indexPath.row == 5 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Location", placeholder: "enter your location", value: Globals.currentAddress, isEdit: false, subItem: false)
                    
                } else if indexPath.row == 6 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("My Grades", placeholder: "select your grades", value: getGradeNames(), isEdit: false, subItem: true)
                    
                } else if indexPath.row == 7 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("My Subjects", placeholder: "select your subjects", value: getSubjectNames(), isEdit: false, subItem: true)
                    
                }
            }
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("SettingsSwitchTableViewCell") as? SettingsSwitchTableViewCell
            if cell == nil {
                cell = SettingsSwitchTableViewCell()
            }
            (cell as? SettingsSwitchTableViewCell)?.configureWithSetting("Enable Push Notifications", delegate: self, tag: 1, enable: false)
        } else if indexPath.section == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier(value1CellIdentifier) as UITableViewCell?
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: value1CellIdentifier)
            }
            Utils.setFontFamilyForView(cell!, includeSubViews: true)
            cell?.detailTextLabel?.text = (myPODS[indexPath.row].isPrivate == 1) ? "Private" : "Public"
            cell?.accessoryType = .DisclosureIndicator
            cell?.textLabel?.text = myPODS[indexPath.row].name
            cell?.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15)
            Utils.setFontFamilyForView(cell!, includeSubViews: true)
        } else if indexPath.section == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier(defaultCellIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: defaultCellIdentifier)
            }
            cell?.textLabel?.text = dolphinItems[indexPath.row]
            cell?.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15)
        } else if indexPath.section == 5 {
            cell = tableView.dequeueReusableCellWithIdentifier(defaultCellIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: defaultCellIdentifier)
            }
            cell?.textLabel?.text = supportItems[indexPath.row]
            cell?.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15)
        }
//        if cell != nil {
        
//        }
//        cell?.contentView.userInteractionEnabled = false
        cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        headerLabel.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        headerLabel.text = titles[section - 1]
        headerLabel.textColor = UIColor.grayColor()
        headerLabel.font = headerLabel.font.fontWithSize(12)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    // MARK: - TableView delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = myPODS[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.prevViewController = self
            navigationController?.pushViewController(podDetailsVC, animated: true)
            
        } else if indexPath.section == 1 {
            if let user = networkController.currentUser {
                if user.isPrivate == 0 && indexPath.row == 6 {
                    selectGrades()
                } else if user.isPrivate == 0  && indexPath.row == 7 {
                    selectSubjects()
                }
            }
        }
        
            //Dolphin.
        else if indexPath.section == 4 {
            
            //Like Us on Facebook.
            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.FacebookURL)!)
            }
                
                //Follow us on Instagram
            else if indexPath.row == 1 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.InstagramURL)!)
            }
                
                //Follow us on Twitter
            else if indexPath.row == 2 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.TwitterURL)!)
            }
                
                //Rate our app
            else if indexPath.row == 3 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.iTunesURL)!)
            }
        }
            
            //Support
        else if indexPath.section == 5 {
            
            //Frequently Asked Questions.
            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.FrequentlyAskedQuestionsURL)!)
            }
                
                //Email Support
            else if indexPath.row == 1 {
                emailSupport()
            }
                
                //Terms of Use
            else if indexPath.row == 2 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.TermsOfUseURL)!)
            }
                
                //Privacy Policy
            else if indexPath.row == 3 {
                UIApplication.sharedApplication().openURL(NSURL(string: Constants.PrivacyPolicyURL)!)
            }
        }
    }
    
    func emailSupport() {
        if MFMailComposeViewController.canSendMail() {
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            mailComposerVC.setToRecipients([Constants.AdminEmail])
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
            
        } else {
            Utils.presentAlertMessage(Constants.Messages.UnsupportedEmailTitle,
                message: Constants.Messages.UnsupportedEmail,
                cancelActionText: "Ok",
                presentingViewContoller: self)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Auxiliary methods
    
    func updateUserInfo() {
        var userNameChanged: Bool = false
        if networkController.currentUser?.isPrivate == 0 {
            // public
            let cellUserName = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? SettingsTextFieldTableViewCell
            if cellUserName?.textFieldValue.text != networkController.currentUser?.userName {
                networkController.currentUser?.userName = cellUserName?.textFieldValue.text
                userNameChanged = true
            }
            let cellFirstName = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) as? SettingsTextFieldTableViewCell
            networkController.currentUser?.firstName = cellFirstName?.textFieldValue.text
            let cellLastName = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 1)) as? SettingsTextFieldTableViewCell
            networkController.currentUser?.lastName = cellLastName?.textFieldValue.text
            
            let cellGender = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 1)) as? SettingsGenderTableViewCell
            networkController.currentUser?.gender = cellGender?.genderSegement.selectedSegmentIndex

            let cellLocation = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 1)) as? SettingsTextFieldTableViewCell
            networkController.currentUser?.location = cellLocation?.textFieldValue.text
            
            var encodedImage: String?
            if let imageToEncode = networkController.currentUser?.userAvatarImageData {
                let resizedImage = Utils.resizeImage(imageToEncode, newWidth: 200)
                encodedImage = Utils.encodeBase64(resizedImage)
            }
            
            // call the api function to update the user info
            SVProgressHUD.showWithStatus("Saving")
            networkController.updateUser(userNameChanged ? networkController.currentUser?.userName : nil,
                                         deviceId: nil,
                                         firstName: networkController.currentUser?.firstName,
                                         lastName: networkController.currentUser?.lastName,
                                         avatarImage: encodedImage,
                                         email: nil,
                                         password: nil,
                                         gender: networkController.currentUser?.gender,
                                         city: Globals.currentCity,
                                         country: Globals.currentCountry,
                                         zip: Globals.currentZip,
                                         location: networkController.currentUser?.location,
                                         isPrivate: networkController.currentUser?.isPrivate, subjects: getSubjectIds(), grades: getGradeIds()) { (user, error) -> () in
                if error == nil {
                    // update the user modified
                    self.networkController.currentUser = user
                    if let imageURLToRemove = user?.userAvatarImageURL {
                        SDImageCache.sharedImageCache().removeImageForKey(imageURLToRemove)
                    }
                    
                    // Store the apiToken
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(Globals.jsonToNSData((user?.toJson())!), forKey: "current_user")
                    defaults.synchronize()
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
            
        } else {
            // private
            
            let cellUserName = tableViewSettings.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? SettingsTextFieldTableViewCell
            if cellUserName?.textFieldValue.text != networkController.currentUser?.userName {
                networkController.currentUser?.userName = cellUserName?.textFieldValue.text
                userNameChanged = true
            }
            
            var encodedImage: String?
            if let imageToEncode = networkController.currentUser?.userAvatarImageData {
                let resizedImage = Utils.resizeImage(imageToEncode, newWidth: 200)
                encodedImage = Utils.encodeBase64(resizedImage)
            }
            
            // call the api function to update the user info
            SVProgressHUD.showWithStatus("Saving")
            networkController.updateUser(userNameChanged ? networkController.currentUser?.userName : nil, deviceId: nil, firstName: nil, lastName: nil, avatarImage: encodedImage, email: nil, password: nil, gender: nil, city: nil, country: nil, zip: nil, location: nil, isPrivate: networkController.currentUser?.isPrivate, subjects: nil, grades: nil) { (user, error) -> () in
                if error == nil {
                    // update the user modified
                    self.networkController.currentUser = user
                    if let imageURLToRemove = user?.userAvatarImageURL {
                        SDImageCache.sharedImageCache().removeImageForKey(imageURLToRemove)
                    }
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
            
        }
    }
    
    func registerCells() {
        tableViewSettings.registerNib(UINib(nibName: "ProfileAvatarTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ProfileAvatarTableViewCell")
        tableViewSettings.registerNib(UINib(nibName: "SettingsTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingsTextFieldTableViewCell")
        tableViewSettings.registerNib(UINib(nibName: "SettingsSwitchTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingsSwitchTableViewCell")
        tableViewSettings.registerNib(UINib(nibName: "SettingsGenderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingsGenderTableViewCell")

    
    }
    
    func setAppearence() {
        tableViewSettings.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func loadData() {
        page = 0
        
        SVProgressHUD.showWithStatus("Loading")
        networkController.filterPOD(nil, userId: networkController.currentUserId, fromDate: nil, toDate: nil, quantity: 100, page: 0, sort_by: nil) { (pods, error) -> () in
            if error == nil {
                
                self.myPODS = pods
                if self.myPODS.count > 0 {
                    // TODO: Remove the message added when the POD table is empty
                } else {
                    // TODO: Put some message if you don't have any POD
                }
                self.tableViewSettings.reloadData()
                SVProgressHUD.dismiss()
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)

                SVProgressHUD.dismiss()
                
            }
        }
    }
    
    // MARK: - ProfileAvatarTableViewCell delegate
    
    func onSelectImageTouchUpInside() {
        resignResponder()
        picker.delegate = self
        let alert = UIAlertController(title: "Choose an image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.view.tintColor = UIColor.blueDolphin()
        let libButton = UIAlertAction(title: "Camera Roll", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.picker.navigationBar.translucent = false
            self.picker.navigationBar.barTintColor = UIColor.blueDolphin()
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Take Photo")
                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.picker, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: {
            //alert.view.tintColor = UIColor.orangeSecondaryGoRun()
        })
    }
    
    
    
    // MARK: - SwitchTableViewCell delegate
    
    func toggleSwitch(enabled: Bool, tag: Int) {
        if tag == 0 {
            // Public/Private
            networkController.currentUser?.isPrivate = enabled ? 0 : 1
            tableViewSettings.reloadData()
        } else if tag == 1 {
            // Push Notifications
        }
    }
    
    // MARK: - SettingsGenderTableViewCellDelegate
    func changedGender(gender: Int) {
        
    }
    
    // MARK: - Actions
    
    func saveSettingsPressed(sender: AnyObject) {
        print("Save Pressed")
        updateUserInfo()
    }
    

    // MARK: - ImagePickController delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let cropController = RSKImageCropViewController(image: chosenImage)
        cropController.delegate = self
        navigationController?.pushViewController(cropController, animated: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    
    // The original image has been cropped.
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        networkController.currentUser?.userAvatarImageData = croppedImage;
        navigationController?.popViewControllerAnimated(true)
        tableViewSettings.reloadData()
        SVProgressHUD.dismiss()
    }

    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    // The original image will be cropped.
    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage)
    {
        // Use when `applyMaskToCroppedImage` set to YES.
        SVProgressHUD.show()
    }
    
    // MARK: - Handle grades and subjects
    
    func selectGrades() {
        
        let pickGradesVC              = PickGradesOrSubjectsViewController()
        pickGradesVC.delegate = self
        pickGradesVC.areSubjects = false
        pickGradesVC.fromSettings = true
        pickGradesVC.gradesSelected = selectedGrades
        pickGradesVC.subjectsSelected = selectedSubjects
        navigationController?.pushViewController(pickGradesVC, animated: true)
    }
    
    func selectSubjects() {
        
        let pickSubjectsVC              = PickGradesOrSubjectsViewController()
        pickSubjectsVC.delegate = self
        pickSubjectsVC.areSubjects = true
        pickSubjectsVC.fromSettings = true
        pickSubjectsVC.gradesSelected = selectedGrades
        pickSubjectsVC.subjectsSelected = selectedSubjects
        navigationController?.pushViewController(pickSubjectsVC, animated: true)
    }
    
    func gradesDidSelected(grades: [Grade]) {
        selectedGrades.removeAll()
        for item in grades {
            selectedGrades.append(item)
        }
        tableViewSettings.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    func subjectsDidSelected(subjects: [Subject]) {
        selectedSubjects.removeAll()
        for item in subjects {
            selectedSubjects.append(item)
        }
        tableViewSettings.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    func getSubjectNames() -> String {
        var subject_name: [String] = []
        
        for item in selectedSubjects {
            subject_name.append(item.name!)
        }

        return subject_name.joinWithSeparator(",")
    }
    
    func getGradeNames() -> String {
        var grade_name: [String] = []
        
        for item in selectedGrades {
            grade_name.append(item.name!)
        }
        return grade_name.joinWithSeparator(",")
    }
    
    func getSubjectIds() -> [String] {
        
        var subject_ids: [String] = []
        for item in selectedSubjects {
            subject_ids.append(String(format: "%d", item.id!))
        }
        return subject_ids
    }
    
    func getGradeIds() -> [String] {
        
        var grade_ids: [String] = []
        
        for item in selectedGrades {
            grade_ids.append(String(format: "%d", item.id!))
        }
        
        return grade_ids
    }
}
