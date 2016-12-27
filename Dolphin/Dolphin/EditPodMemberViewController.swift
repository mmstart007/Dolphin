//
//  EditPodMemberViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 7/28/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditPodMemberViewController: DolphinViewController, PODMemberToAddTableViewCellDelegate, SelectPODMembersDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var pod: POD?
    let networkController = NetworkController.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Edit Members"
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "PlusIconSmall"), style: .plain, target: self, action: #selector(addNewMember))
        rightButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightButton

        setBackButton()
        tableView.register(UINib(nibName: "PODMemberToAddTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
    }

    func addNewMember() {
        let selectMembersVC = SelectPODMembersViewController()
        selectMembersVC.delegate = self
        selectMembersVC.selectedMembers = pod!.users!
        navigationController?.pushViewController(selectMembersVC, animated: true)
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pod?.users!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PODMemberToAddTableViewCell") as? PODMemberToAddTableViewCell
        if cell == nil {
            cell = PODMemberToAddTableViewCell()
        }
        cell!.configureWithUser((pod?.users![indexPath.row])!, isAdded: true, index: indexPath.row)
        cell!.delegate = self
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func deleteMember(_ user: User?, index: Int) {
        pod?.users?.remove(at: index)
        var retDic = [String: AnyObject]()
        
        if let podId = pod!.id {
            retDic["id"] = podId as AnyObject?
        }
        
        if let usrs = pod!.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds as AnyObject?
        }
        
        SVProgressHUD.show()
        networkController.updatePod(retDic as NSDictionary) { (updatedPod, error) in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()            
        }
    }
    
    
    // MARK: - SelectPODMembersDelegate
    func membersDidSelected(_ members: [User]) {
        pod?.users = members
        var retDic = [String: AnyObject]()
        
        if let podId = pod!.id {
            retDic["id"] = podId as AnyObject?
        }
        
        if let usrs = pod!.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds as AnyObject?
        }
        
        SVProgressHUD.show()
        networkController.updatePod(retDic as NSDictionary) { (updatedPod, error) in
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
}
