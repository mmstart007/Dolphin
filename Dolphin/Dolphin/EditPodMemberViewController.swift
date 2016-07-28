//
//  EditPodMemberViewController.swift
//  Dolphin
//
//  Created by Joachim on 7/28/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditPodMemberViewController: DolphinViewController, PODMemberToAddTableViewCellDelegate, SelectPODMembersDelegate {

    @IBOutlet weak var tableView: UITableView!

    var pod: POD?
    let networkController = NetworkController.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Edit Members"
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "PlusIconSmall"), style: .Plain, target: self, action: #selector(addNewMember))
        rightButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightButton

        setBackButton()
        tableView.registerNib(UINib(nibName: "PODMemberToAddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
    }

    func addNewMember() {
        let selectMembersVC = SelectPODMembersViewController()
        selectMembersVC.delegate = self
        selectMembersVC.selectedMembers = pod!.users!
        navigationController?.pushViewController(selectMembersVC, animated: true)
    }

    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pod?.users!.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PODMemberToAddTableViewCell") as? PODMemberToAddTableViewCell
        if cell == nil {
            cell = PODMemberToAddTableViewCell()
        }
        cell!.configureWithUser((pod?.users![indexPath.row])!, isAdded: true, index: indexPath.row)
        cell!.delegate = self
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func deleteMember(user: User?, index: Int) {
        pod?.users?.removeAtIndex(index)
        var retDic = [String: AnyObject]()
        
        if let podId = pod!.id {
            retDic["id"] = podId
        }
        
        if let usrs = pod!.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds
        }
        
        SVProgressHUD.show()
        networkController.updatePod(retDic) { (updatedPod, error) in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()            
        }
    }
    
    
    // MARK: - SelectPODMembersDelegate
    func membersDidSelected(members: [User]) {
        pod?.users = members
        var retDic = [String: AnyObject]()
        
        if let podId = pod!.id {
            retDic["id"] = podId
        }
        
        if let usrs = pod!.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds
        }
        
        SVProgressHUD.show()
        networkController.updatePod(retDic) { (updatedPod, error) in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
}
