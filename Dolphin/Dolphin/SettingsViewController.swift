//
//  SettingsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/7/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource, SettingsSwitchTableViewCellDelegate {
    
    let networkController = NetworkController.sharedInstance
    let titles = ["PROFILE", "PUSH NOTIFICATIONS", "MY PODS", "DOLPHIN", "SUPPORT"]
    let dolphinItems = ["Like us on Facebook", "Follow us on Instagram", "Follow us on Twitter", "Rate our app"]
    let supportItems = ["Frequently Asked Questions", "Email Support", "Terms of Use", "Privacy Policy"]

    @IBOutlet weak var tableViewSettings: UITableView!
    
    var myPODS: [POD] = []
    var publicProfile: Bool = false
    
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
        setRightButtonItemWithText("Save", target: self, action: Selector("saveSettingsPressed:"))
        tableViewSettings.delegate = self
        tableViewSettings.dataSource = self
        registerCells()
        // TODO: loads pods from server
        //myPODS = networkController.pods
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // profile
            if publicProfile {
                return 5
            } else {
                return 2
            }
        case 1:
            // push notifications
            return 1
        case 2:
            // my pods
            return myPODS.count
        case 3:
            // dolphin
            return dolphinItems.count
        case 4:
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
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                if cell == nil {
                    cell = SettingsTextFieldTableViewCell()
                }
                (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Username", placeholder: "username")
            }
            else {
                if indexPath.row == 1 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsSwitchTableViewCell") as? SettingsSwitchTableViewCell
                    if cell == nil {
                        cell = SettingsSwitchTableViewCell()
                    }
                    (cell as? SettingsSwitchTableViewCell)?.configureWithSetting("Private/Public", delegate: self, tag: 0)
                    
                } else if indexPath.row == 2 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("First Name", placeholder: "enter your name")
                    
                } else if indexPath.row == 3 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Last Name", placeholder: "enter your last name")
                    
                } else if indexPath.row == 4 {
                    cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextFieldTableViewCell") as? SettingsTextFieldTableViewCell
                    if cell == nil {
                        cell = SettingsTextFieldTableViewCell()
                    }
                    (cell as? SettingsTextFieldTableViewCell)?.configureWithSetting("Location", placeholder: "enter your location")
                    
                }
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("SettingsSwitchTableViewCell") as? SettingsSwitchTableViewCell
            if cell == nil {
                cell = SettingsSwitchTableViewCell()
            }
            (cell as? SettingsSwitchTableViewCell)?.configureWithSetting("Enable Push Notifications", delegate: self, tag: 1)
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier(value1CellIdentifier) as UITableViewCell?
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: value1CellIdentifier)
            }
            cell?.detailTextLabel?.text = (myPODS[indexPath.row].podIsPrivate) ? "Private" : "Public"
            cell?.accessoryType = .DisclosureIndicator
            cell?.textLabel?.text = myPODS[indexPath.row].podName
        } else if indexPath.section == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier(defaultCellIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: defaultCellIdentifier)
            }
            cell?.textLabel?.text = dolphinItems[indexPath.row]
        } else if indexPath.section == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier(defaultCellIdentifier)
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: defaultCellIdentifier)
            }
            cell?.textLabel?.text = supportItems[indexPath.row]
        }
        if cell != nil {
            Utils.setFontFamilyForView(cell!, includeSubViews: true)
        }
        cell?.contentView.userInteractionEnabled = false
        cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Header for comments
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 10, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        headerLabel.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        headerLabel.text = titles[section]
        headerLabel.textColor = UIColor.grayColor()
        headerLabel.font = headerLabel.font.fontWithSize(12)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    // MARK: - TableView delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let PODSettingsVC = PODSettingsViewController(pod: myPODS[indexPath.row])
            navigationController?.pushViewController(PODSettingsVC, animated: true)
        }
    }
    
        
    // MARK: - Auxiliary methods
    
    func loadUserInfo() {
        SVProgressHUD.showWithStatus("Loading")
        networkController.getUserById("\(networkController.currentUserId)") { (user, error) -> () in
            if error == nil {
                if user?.id != nil {
                    self.networkController.currentUser = user
                    // everything worked ok
                    //loadFields()
                } else {
                    print("there was an error getting the user info")
                }
                
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
    
    func registerCells() {
        tableViewSettings.registerNib(UINib(nibName: "SettingsTextFieldTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingsTextFieldTableViewCell")
        tableViewSettings.registerNib(UINib(nibName: "SettingsSwitchTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SettingsSwitchTableViewCell")
    
    }
    
    func setAppearence() {
        tableViewSettings.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    // MARK: - SwitchTableViewCell delegate
    
    func toggleSwitch(enabled: Bool, tag: Int) {
        if tag == 0 {
            // Public/Private
            publicProfile = enabled
            tableViewSettings.reloadData()
        } else if tag == 1 {
            // Push Notifications
        }
    }
    
    // MARK: - Actions
    
    func saveSettingsPressed(sender: AnyObject) {
        print("Save Pressed")
    }


}
