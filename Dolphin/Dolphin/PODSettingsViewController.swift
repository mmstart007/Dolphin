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
        super.init(nibName: "PODSettingsViewController", bundle: Bundle.main)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete", message: "Do you want to remove this member from the POD?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                NetworkController.sharedInstance.deletePodMember(String(self.pod!.id!), userId: String(self.members[indexPath.row].id!), completionHandler: { (error) in
                    if error == nil {
                        self.members.remove(at: indexPath.row)
                        self.tableViewPODMembers.reloadSections(IndexSet(integer: 0), with: .automatic)
                    } else {
                        Utils.presentAlertMessage("Error", message: "An error occurred trying to delete the member", cancelActionText: "Ok", presentingViewContoller: self)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FriendToInviteTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "FriendToInviteTableViewCell") as? FriendToInviteTableViewCell
        if cell == nil {
            cell = FriendToInviteTableViewCell()
        }
        
        cell?.configureWithPODMember(members[indexPath.row])
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func registerCells() {
        tableViewPODMembers.register(UINib(nibName: "FriendToInviteTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "FriendToInviteTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 25))
        headerLabel.text = "Members"
        headerLabel.textColor = UIColor.gray
        headerLabel.font = headerLabel.font.withSize(11)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let subViewsArray = Bundle.main.loadNibNamed("PODSettingsFooter", owner: self, options: nil)
        let footerViewFromNib = subViewsArray![0] as? UIView
        footerViewFromNib?.isUserInteractionEnabled = true
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        footerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
        footerView.addSubview(footerViewFromNib!)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTouchUpInside(_ sender: AnyObject) {
        print("Delete pressed")
        
        let alertWarning = UIAlertController(title: "Warning", message: "Are you sure your work with this POD is complete?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertWarning.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            // ask to delete again
            let alertDeleteConfirmation = UIAlertController(title: "Delete", message: "Do you want to delete this POD?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertDeleteConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                // delete the pod
                let podIdString = String(self.pod!.id!)
                self.networkController.deletePOD(podIdString) { (error) -> () in
                    if error == nil {
                        print("pod deleted")
                        let _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        let errors: [String]? = error!["errors"] as? [String]
                        let alert: UIAlertController
                        if errors != nil && errors![0] != "" {
                            alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                        } else {
                            alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                        }
                        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }))
            alertDeleteConfirmation.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alertDeleteConfirmation, animated: true, completion: nil)
            
            
        }))
        alertWarning.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alertWarning, animated: true, completion: nil)

    }
    
    
}
