//
//  SelectPODMembersViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

protocol SelectPODMembersDelegate {
    func membersDidSelected(members: [User])
}

class SelectPODMembersViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PODMemberToAddTableViewCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let networkController = NetworkController.sharedInstance
    var delegate: SelectPODMembersDelegate?
    var selectedMembers: [User] = []
    var searchResults: [User] = []
    
    required init() {
        super.init(nibName: "SelectPODMembersViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "POD Members"
        setRightButtonItemWithText("Done", target: self, action: Selector("doneSelectingMembersPressed:"))
        setBackButton()
        
        searchResults = []
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "PODMemberToAddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
        
        showSearchBar()
        filterContentForSearchText("", isFirstLoading: true)
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PODMemberToAddTableViewCell") as? PODMemberToAddTableViewCell
        if cell == nil {
            cell = PODMemberToAddTableViewCell()
        }
        cell!.configureWithUser(searchResults[indexPath.row], isAdded: false, index: indexPath.row)
        cell!.delegate = self
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableViewDelegate
    
    func addMember(user: User?, index: Int) {
        selectedMembers.append(searchResults[index])
        searchResults.removeAtIndex(index)
        
        self.tableView.reloadData()
    }
    
    // MARK: - Handle SearchBar
    
    func showSearchBar() {
        searchBar?.tintColor = UIColor.whiteColor()
        searchBar?.barTintColor = UIColor.blueDolphin()
        UITextField.my_appearanceWhenContainedWithin([UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        UIBarButtonItem.my_appearanceWhenContainedWithin([UISearchBar.classForCoder()]).tintColor = UIColor.whiteColor()
        UIView.my_appearanceWhenContainedWithin([UISearchBar.classForCoder()]).tintColor = UIColor.whiteColor()

        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText, isFirstLoading: false)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignResponder()
        searchResults = []
        searchBar.text = ""
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, isFirstLoading: Bool) {
        if isFirstLoading == true {
            SVProgressHUD.show()
        }
        networkController.filterUser(searchText, podId: nil, fromDate: nil, toDate: nil, quantity: 10, page: 0) { (users, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                self.searchResults = users.filter({ (user) -> Bool in
                    if user.id == self.networkController.currentUserId {
                        return false
                    }
                    
                    for u in self.selectedMembers {
                        if u.id == user.id {
                            return false
                        }
                    }
                    return true
                })
                self.tableView.reloadData()
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                var alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
    }
    
    // MARK: - Auxiliary methods
    func doneSelectingMembersPressed(sender: AnyObject) {
        delegate?.membersDidSelected(selectedMembers)
        navigationController?.popViewControllerAnimated(true)
    }

    
}
