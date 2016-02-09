//
//  NewPostPrivacySettingsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class NewPostPrivacySettingsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate {
 
    struct VisibilitySetting {
        
        var name: String?
        var image: String?
        
        init(settingName: String, settingImage: String, settingInformativeText: String) {
            
            name            = settingName
            image           = settingImage
            
        }
        
    }
    
    struct PODSharePrivacySetting {
        
        var pod: POD?
        var selected: Bool
        
        
        init(pod: POD, selected: Bool) {
            self.pod      = pod
            self.selected = selected
        }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var privacySettings: [VisibilitySetting] = []
    var podShareSettings: [PODSharePrivacySetting] = []
    var selectedPrivacySettingIndex: Int = 0
    
    convenience init() {
        self.init(nibName: "NewPostPrivacySettingsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRightSystemButtonItem(.Done, target: self, action: "dismissButtonPressed:")
        title = "Post Privacy Settings"
        
        tableView.registerNib(UINib(nibName: "NewPostPrivacySettingsVisibilityCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "NewPostPrivacySettingsVisibilityCell")
        tableView.registerNib(UINib(nibName: "NewPostPrivacySettingsShareToPODCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "NewPostPrivacySettingsShareToPODCell")
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle  = .None
        
        setupFields()
    }
    
    func setupFields() {
        
        let setting1 = VisibilitySetting(settingName: "Public", settingImage: "EarthIcon", settingInformativeText: "People who are not friends with you can see this post when their friends share it.")
        privacySettings.append(setting1)
        tableView.reloadData()
     
        for pod in NetworkController.sharedInstance.pods {
            let podShareSetting  = PODSharePrivacySetting(pod: pod, selected: false)
            podShareSettings.append(podShareSetting)
        }
        
    }
    
    // MARK: TableView DataSource
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 60))
        headerView.backgroundColor = UIColor.lightGrayBackground()
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 30, width: UIScreen.mainScreen().bounds.width - 20, height: 30))
        titleLabel.textColor = UIColor.lightGrayColor()
        headerView.addSubview(titleLabel)
        titleLabel.text = "Share to PODs"
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 60
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return privacySettings.count
        } else {
            return podShareSettings.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("NewPostPrivacySettingsVisibilityCell") as? NewPostPrivacySettingsVisibilityCell
            if cell == nil {
                cell = NewPostPrivacySettingsVisibilityCell()
            }
            (cell as? NewPostPrivacySettingsVisibilityCell)!.configureWithVisibilitySetting(privacySettings[indexPath.row], selected: indexPath.row == selectedPrivacySettingIndex)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("NewPostPrivacySettingsShareToPODCell") as? NewPostPrivacySettingsShareToPODCell
            if cell == nil {
                cell = NewPostPrivacySettingsShareToPODCell()
            }
            (cell as? NewPostPrivacySettingsShareToPODCell)?.configureWithPODPrivacySetting(podShareSettings[indexPath.row])
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            selectedPrivacySettingIndex = indexPath.row
            for (var i = 0; i < podShareSettings.count; i++) {
                podShareSettings[i].selected = false
            }
        } else {
            selectedPrivacySettingIndex = -1
            podShareSettings[indexPath.row].selected = !podShareSettings[indexPath.row].selected
            var oneSelected = false
            for (var i = 0; i < podShareSettings.count; i++) {
                if podShareSettings[i].selected == true {
                    oneSelected = true
                }
            }
            if !oneSelected {
                selectedPrivacySettingIndex = 0
            }
        }
        tableView.reloadData()
    }
    
}