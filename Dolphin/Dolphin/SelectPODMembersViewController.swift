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
    func membersDidSelected(_ members: [User])
}

class SelectPODMembersViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PODMemberToAddTableViewCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let networkController = NetworkController.sharedInstance
    var delegate: SelectPODMembersDelegate?
    var selectedMembers: [User] = []
    var searchResults: [User] = []
    
    required init() {
        super.init(nibName: "SelectPODMembersViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "POD Members"
        setRightButtonItemWithText("Done", target: self, action: #selector(doneSelectingMembersPressed(_:)))
        setBackButton()
        
        searchResults = []
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "PODMemberToAddTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
        
        showSearchBar()
        filterContentForSearchText("", isFirstLoading: true)
    }
    
    override func keyboardWillShow(_ sender: Foundation.Notification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.bottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func keyboardWillHide(_ notification: Foundation.Notification) {
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PODMemberToAddTableViewCell") as? PODMemberToAddTableViewCell
        if cell == nil {
            cell = PODMemberToAddTableViewCell()
        }
        cell!.configureWithUser(searchResults[indexPath.row], isAdded: false, index: indexPath.row)
        cell!.delegate = self
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableViewDelegate
    
    func addMember(_ user: User?, index: Int) {
        selectedMembers.append(searchResults[index])
        searchResults.remove(at: index)
        
        self.tableView.reloadData()
    }
    
    // MARK: - Handle SearchBar
    
    func showSearchBar() {
        searchBar?.tintColor = UIColor.white
        searchBar?.barTintColor = UIColor.blueDolphin()
        UITextField.my_appearanceWhenContained(within: [UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        UIBarButtonItem.my_appearanceWhenContained(within: [UISearchBar.classForCoder()]).tintColor = UIColor.white
        UIView.my_appearanceWhenContained(within: [UISearchBar.classForCoder()]).tintColor = UIColor.white

        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText, isFirstLoading: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resignResponder()
        searchBar.text = ""
//        searchResults = []        
//        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchText: String, isFirstLoading: Bool) {
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
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)

            }
        }
    }
    
    // MARK: - Auxiliary methods
    func doneSelectingMembersPressed(_ sender: AnyObject) {
        delegate?.membersDidSelected(selectedMembers)
        let _ = navigationController?.popViewController(animated: true)
    }
}
