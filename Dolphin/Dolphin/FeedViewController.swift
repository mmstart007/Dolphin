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

class FeedViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate {
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 10
    
    @IBOutlet weak var postsTableView: UITableView!
    
    var cells: [PostTableViewCell] = []
    var myLikes: Bool = false
    var allPosts: [Post] = []
    var filteredPosts: [Post] = []
    var searchText: String? = nil
    var isDataLoaded: Bool = false
    var postIdsOfLikesForTheUser: [Int] = []
    var page: Int = 0
    
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
        if networkController.currentUserId == nil {
            let alert = UIAlertController(title: "Warning", message: "You need to logout and login again, sorry this is for this time because we are in development", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            if !isDataLoaded {
                loadData(false)
            }
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
        
        postsTableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadNextPosts()
        }
        
        //Notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createdNewPost:", name: Constants.Notifications.CreatedPost, object: nil)
        
    }
    
    func createdNewPost(note: NSNotification) {
        
        if let info = note.userInfo as? Dictionary<String, Post> {
            if let post:Post = info["post"] {
                self.allPosts.insert(post, atIndex: 0)
                self.postsTableView.reloadData()
            }
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
        cell?.delegate = self
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
    
    // MARK: PostTableViewCell Delegate.
    
    func tapURL(url: String?) {
        let webVC = WebViewController()
        webVC.siteLink = url
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func tapLike(post: Post?, cell: PostTableViewCell?) {
        if !(post?.isLikedByUser)! {
            SVProgressHUD.showWithStatus("Loading")
            networkController.createLike("\(post!.postId!)", completionHandler: { (like, error) -> () in
                if error == nil {
                    if like?.id != nil {
                        post?.isLikedByUser = true
                        post?.postNumberOfLikes = (post?.postNumberOfLikes)! + 1
                        cell?.configureWithPost(post!)
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            
            SVProgressHUD.showWithStatus("Loading")
            networkController.deleteLike("\(post!.postId!)", completionHandler: { (error) -> () in
                if error == nil {
                    post?.postNumberOfLikes = (post?.postNumberOfLikes)! - 1
                    post?.isLikedByUser = false
                    cell?.configureWithPost(post!)
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        }
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
    
    
    // Not used for now, the post has if the user likes it or not
    func loadUserLikes(pullToRefresh: Bool) {
        networkController.getUserLikes(String(networkController.currentUserId!)) { (likes, error) -> () in
            if error == nil {
                // build the list of post liked by the user
                self.postIdsOfLikesForTheUser = likes.map({ (actual) -> Int in
                    actual.likePost!.postId!
                })
                // load the feeds
                self.loadData(pullToRefresh)
                
            } else {
                self.isDataLoaded = false
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
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                self.postsTableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func loadData(pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: 0, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.isDataLoaded = true
                self.allPosts = posts
                if self.allPosts.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No content has been posted\n\nwhy don't post someting?")
                }
                self.postsTableView.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                //self.deletePost(4)
                
            } else {
                self.isDataLoaded = false
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
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
            }
            self.postsTableView.pullToRefreshView.stopAnimating()
        })
    }
    
    func deletePost(postId: Int) {
        let postIdString = String(postId)
        networkController.deletePost(postIdString) { (error) -> () in
            if error == nil {
                print("post deleted")
            } else {
                
            }
            self.postsTableView.pullToRefreshView.stopAnimating()
        }
    }
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: page, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.allPosts.appendContentsOf(posts)
                self.postsTableView.reloadData()
                
                
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
            self.postsTableView.infiniteScrollingView.stopAnimating()
        })
    }
    
    func addTableEmptyMessage(message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: postsTableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .Center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        postsTableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        postsTableView.backgroundView = nil
    }
    
}
