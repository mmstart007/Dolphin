//
//  FeedViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postsTableView: UITableView!
    
    let networkController = NetworkController.sharedInstance
    var cells: [PostTableViewCell] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.postsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        postsTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        postsTableView.separatorStyle = .None
        postsTableView.estimatedRowHeight = 1000

    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkController.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PostTableViewCell? = postsTableView.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
        if cell == nil {
            cell = PostTableViewCell()
        }
        cell?.configureWithPost(networkController.posts[indexPath.row])
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as? PostTableViewCell {
            postCell.adjustCellViews(networkController.posts[indexPath.row])
        }
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let postDetailsVC = PostDetailsViewController()
        postDetailsVC.post = networkController.posts[indexPath.row]
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
    
}
