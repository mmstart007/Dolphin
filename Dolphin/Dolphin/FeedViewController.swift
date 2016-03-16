//
//  FeedViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class FeedViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postsTableView: UITableView!
    
    let networkController = NetworkController.sharedInstance
    var cells: [PostTableViewCell] = []
    var myLikes: Bool = false
    var allPosts: [Post] = []
    var filteredPosts: [Post] = []
    var searchText: String? = nil
    var isDataLoaded: Bool = false

    init(likes: Bool) {
        super.init(nibName: "FeedViewController", bundle: nil)
        self.myLikes = likes
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.postsTableView.reloadData()
        if !isDataLoaded {
            loadData(false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        searchText = ""
        (self.parentViewController as? HomeViewController)?.removeSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if myLikes {
            setBackButton()
            title = "My Likes"
        }
        self.edgesForExtendedLayout = .None
        postsTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        postsTableView.separatorStyle     = .None
        postsTableView.estimatedRowHeight = 400
        
        postsTableView.addPullToRefreshWithActionHandler { () -> Void in
            self.loadData(true)
        }

    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myLikes {
            return networkController.likedPosts.count
        } else {
            if searchText != nil && searchText != "" {
                return filteredPosts.count
            } else {
                return allPosts.count
            }
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PostTableViewCell? = postsTableView.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
        if cell == nil {
            cell = PostTableViewCell()
        }
        if myLikes {
            cell?.configureWithPost(networkController.likedPosts[indexPath.row])
        } else {
            if searchText != nil && searchText != "" {
                cell?.configureWithPost(filteredPosts[indexPath.row])
            } else {
                cell?.configureWithPost(allPosts[indexPath.row])
            }
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let postDetailsVC = PostDetailsViewController()
        if myLikes {
            postDetailsVC.post = networkController.likedPosts[indexPath.row]
        } else {
            if searchText != nil && searchText != "" {
                postDetailsVC.post = filteredPosts[indexPath.row]
            } else {
                postDetailsVC.post = allPosts[indexPath.row]
            }
            
        }
        
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? PostTableViewCell)?.adjustViews()
    }
    
    // MARK: Search Posts
    
    func filterResults(textToSearch: String) {
        print("Search text: \(textToSearch)")
        filteredPosts = allPosts.filter({( post : Post) -> Bool in
            return (post.postText?.lowercaseString.containsString(textToSearch.lowercaseString))!
        })
        searchText = textToSearch
        postsTableView.reloadData()
    }
    
    func userDidCancelSearch() {
        print("User cancelled search")
        searchText = ""
        postsTableView.reloadData()
    }
    
    // MARK: - Auxiliary methods
    func loadData(pullToRefresh: Bool) {
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        networkController.getAllPost { (posts, error) -> () in
            if error == nil {
                self.isDataLoaded = true
                self.allPosts = posts
                self.postsTableView.reloadData()
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                //self.loadTest()
                
            } else {
                self.isDataLoaded = false
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
            }
            self.postsTableView.pullToRefreshView.stopAnimating()
        }
    }
    
    func loadTest() {
        networkController.getUserComments("23") { (likes, error) -> () in
            if error == nil {
                print("user likes succesffully fetched")
            } else {
                
            }
            self.postsTableView.pullToRefreshView.stopAnimating()
        }
    }
    
}
