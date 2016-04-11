//
//  PODSettingsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class PODSettingsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource {

    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var tableViewPODMembers: UITableView!
    
    var members: [User] = []
    var pod: POD?
    
    required init() {
        super.init(nibName: "PODSettingsViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pod: POD) {
        super.init(nibName: "PODSettingsViewController", bundle: nil)
        self.pod = pod
        members = pod.users!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewPODMembers.dataSource = self
        tableViewPODMembers.delegate = self
        registerCells()
        setBackButton()
        title = pod?.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView delegate
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let alert = UIAlertController(title: "Delete", message: "Do you want to remove this member from the POD?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
                self.members.removeAtIndex(indexPath.row)
                self.tableViewPODMembers.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                
                
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return members.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
        if cell == nil {
            cell = FriendToInviteTableViewCell()
        }
        
        cell?.configureWithPODMember(members[indexPath.row])
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func registerCells() {
        tableViewPODMembers.registerNib(UINib(nibName: "FriendToInviteTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FriendToInviteTableViewCell")
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 25))
        headerLabel.text = "Members"
        headerLabel.textColor = UIColor.grayColor()
        headerLabel.font = headerLabel.font.fontWithSize(11)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let subViewsArray = NSBundle.mainBundle().loadNibNamed("PODSettingsFooter", owner: self, options: nil)
        let footerViewFromNib = subViewsArray[0] as? UIView
        footerViewFromNib?.userInteractionEnabled = true
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        footerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
        footerView.addSubview(footerViewFromNib!)
        
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTouchUpInside(sender: AnyObject) {
        print("Delete pressed")
        
        let alertWarning = UIAlertController(title: "Warning", message: "Are you sure your work with this POD is complete?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertWarning.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
            // ask to delete again
            let alertDeleteConfirmation = UIAlertController(title: "Delete", message: "Do you want to delete this POD?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertDeleteConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
                // delete the pod
                let podIdString = String(self.pod!.id!)
                self.networkController.deletePOD(podIdString) { (error) -> () in
                    if error == nil {
                        print("pod deleted")
                        self.navigationController?.popViewControllerAnimated(true)
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
                
            }))
            alertDeleteConfirmation.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alertDeleteConfirmation, animated: true, completion: nil)
            
            
        }))
        alertWarning.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // show the alert
        self.presentViewController(alertWarning, animated: true, completion: nil)

    }
    
    
}
