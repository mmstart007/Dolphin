//
//  NewPostPrivacySettingsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

protocol NewPostPrivacySettingsViewControllerDelegate {
    func didFinishSettingOptions(selectedPods: [POD])
}

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
    var privacySettings: [VisibilitySetting]       = []
    var podShareSettings: [PODSharePrivacySetting] = []
    var selectedPrivacySettingIndex: Int           = 0
    var selectedPODs: [POD]!
    let networkController                          = NetworkController.sharedInstance
    var delegate: NewPostPrivacySettingsViewControllerDelegate?
    
    convenience init(selectedPODs: [POD], delegate: NewPostPrivacySettingsViewControllerDelegate) {
        self.init(nibName: "NewPostPrivacySettingsViewController", bundle: nil)
        self.selectedPODs = selectedPODs
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightSystemButtonItem(.Done, target: self, action: "doneButtonPressed:")
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
        
        if selectedPODs.count > 0 {
            selectedPrivacySettingIndex = -1
        }
        let setting1 = VisibilitySetting(settingName: "Public", settingImage: "EarthIcon", settingInformativeText: "People who are not friends with you can see this post when their friends share it.")
        privacySettings.append(setting1)
        tableView.reloadData()
        getMyPODs()
    }
    
    func getMyPODs() {
        SVProgressHUD.showWithStatus("Loading")
        networkController.filterPOD(nil, userId: networkController.currentUserId, fromDate: nil, toDate: nil, quantity: 100, page: 0, sort_by: "") { (pods, error) -> () in
            SVProgressHUD.dismiss()
            if error == nil {
                for pod in pods {
                    var selected = false
                    for selectedPOD in self.selectedPODs {
                        if pod.id == selectedPOD.id {
                            selected = true
                        }
                    }
                    let podShareSetting  = PODSharePrivacySetting(pod: pod, selected: selected)
                    self.podShareSettings.append(podShareSetting)
                }
                self.tableView.reloadData()
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
            }
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
            let oneSelected = podShareSettings[indexPath.row].selected
            for (var i = 0; i < podShareSettings.count; i++) {
                if i != indexPath.row {
                    podShareSettings[i].selected = false
                }
            }
            if !oneSelected {
                selectedPrivacySettingIndex = 0
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    func doneButtonPressed(sender: AnyObject) {
        
        var selectedPODs: [POD] = []
        for podSetting in podShareSettings {
            if let podToAdd = podSetting.pod where podSetting.selected {
                selectedPODs.append(podToAdd)
            }
        }
        delegate?.didFinishSettingOptions(selectedPODs)
        navigationController?.popViewControllerAnimated(true)
    }
    
}