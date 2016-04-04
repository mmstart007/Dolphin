//
//  SelectPODMembersViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

protocol SelectPODMembersDelegate {
    func membersDidSelected(members: [User])
}

class SelectPODMembersViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: SelectPODMembersDelegate?
    var searchTableView: UITableView?
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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "PODMemberToAddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
            
        
        showSearchBar()
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return selectedMembers.count
        } else {
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PODMemberToAddTableViewCell") as? PODMemberToAddTableViewCell
        if cell == nil {
            cell = PODMemberToAddTableViewCell()
        }
        if tableView == self.tableView {
            cell!.configureWithUser(selectedMembers[indexPath.row], isAdded: true)
        } else {
            cell!.configureWithUser(searchResults[indexPath.row], isAdded: false)
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableView {
            selectedMembers.removeAtIndex(indexPath.row)
        } else {
            selectedMembers.append(searchResults[indexPath.row])
            searchResults.removeAtIndex(indexPath.row)
        }
        refreshTables()
    }
    
    // MARK: - Handle SearchBar
    
    func showSearchBar() {
        if searchTableView == nil {
            searchTableView = UITableView(frame: CGRect(x: 0, y: searchBar.frame.size.height, width: view.frame.size.width, height: 0))
            view.addSubview(searchTableView!)
            searchTableView!.backgroundColor = UIColor.lightGrayBackground()
            searchTableView!.registerNib(UINib(nibName: "PODMemberToAddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODMemberToAddTableViewCell")
            searchTableView!.dataSource = self
            searchTableView!.delegate   = self
        }
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
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignResponder()
        searchResults = []
        searchBar.text = ""
        refreshTables()
    }
    
    func refreshTables() {
        var newHeight = CGFloat(self.searchResults.count * 60)
        
        if newHeight > UIScreen.mainScreen().bounds.height / 3.0 {
            newHeight = UIScreen.mainScreen().bounds.height / 3.0
        }
        let tableFrame = self.searchTableView!.frame
        let newFrame = CGRect(x: tableFrame.origin.x, y: tableFrame.origin.y, width: tableFrame.size.width, height: newHeight)
        searchTableView!.frame = newFrame
        searchTableView!.reloadData()
        tableView.reloadData()
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        let labelFooter = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        labelFooter.textAlignment = .Center
        labelFooter.textColor = UIColor.lightGrayColor()
        labelFooter.text = String(format: "%i contacts selected", selectedMembers.count)
        footerView.addSubview(labelFooter)
        Utils.setFontFamilyForView(footerView, includeSubViews: true)
        tableView.tableFooterView = footerView
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        NetworkController.sharedInstance.filterUser(searchText, podId: nil, fromDate: nil, toDate: nil, quantity: 10, page: 0) { (users, error) in
            if error == nil {
                self.searchResults = users.filter({ (user) -> Bool in
                    return !self.selectedMembers.contains(user)
                })
                
                self.refreshTables()
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
