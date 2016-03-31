//
//  SelectPODMembersViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class SelectPODMembersViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
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
        setBackButton()
        
        tableView.dataSource = self
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
            cell!.configureWithUser(selectedMembers[indexPath.row])
        } else {
            cell!.configureWithUser(searchResults[indexPath.row])
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
            
        } else {
            selectedMembers.append(searchResults[indexPath.row])
            tableView.reloadData()
        }
    }
    
    // MARK: - Handle SearchBar
    
    func showSearchBar() {
        if searchTableView == nil {
            searchTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            view.addSubview(searchTableView!)
            searchTableView!.backgroundColor = UIColor.groupTableViewBackgroundColor()
            searchTableView!.dataSource = self
            searchTableView!.delegate   = self
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignResponder()
    }
    
    func filterContentForSearchText(searchText: String) {
        
        var newHeight = CGFloat(searchResults.count * 60)
        
        if newHeight > UIScreen.mainScreen().bounds.height / 2.0 {
            newHeight = UIScreen.mainScreen().bounds.height / 2.0
        }
        let tableFrame = searchTableView!.frame
        let newFrame = CGRect(x: tableFrame.origin.x, y: tableFrame.origin.y, width: tableFrame.size.width, height: newHeight)
        searchTableView!.frame = newFrame
        searchTableView!.reloadData()
    }

    
}
