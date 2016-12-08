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
    var likedPosts: [Post] = []
    
    var searchText: String? = nil
    var isDataLoaded: Bool = false
//    var postIdsOfLikesForTheUser: [Int] = []
    var page: Int = 0
    
    init(likes: Bool) {
        super.init(nibName: "FeedViewController", bundle: nil)
        self.myLikes = likes
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.postsTableView.reloadData()
        self.postsTableView.estimatedRowHeight = 470
        
        if networkController.currentUserId == nil {
            let alert = UIAlertController(title: "Warning", message: "You need to logout and login again, sorry this is for this time because we are in development", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            
            //Set notification handler to get posted feed.
            NotificationCenter.default.addObserver(self, selector: #selector(newPostCreated(_:)) , name: NSNotification.Name(rawValue: Constants.Notifications.CreatedPost), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(postRemoved(_:)) , name: NSNotification.Name(rawValue: Constants.Notifications.DeletedPost), object: nil)
            
            if !isDataLoaded {
                if myLikes {
                    loadUserLikes(false)
                } else {
                    loadData(false)
                }
            }
        }
    }
    
    func postRemoved(_ notification: Foundation.Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, Post> {
            if let post = userInfo["post"] {
                var index = 0;
                
                for item in self.allPosts {
                    if item.postId == post.postId {
                        self.allPosts.remove(at: index)
                        break
                    }
                    
                    index += 1
                }
                
                index = 0;
                for item in self.filteredPosts {
                    if item.postId == post.postId {
                        self.filteredPosts.remove(at: index)
                        break
                    }
                    
                    index += 1
                }
                
                index = 0;
                for item in self.likedPosts {
                    if item.postId == post.postId {
                        self.likedPosts.remove(at: index)
                        break
                    }
                    
                    index += 1
                }
                
                self.postsTableView.reloadData()
            }
        }
    }
    
    func newPostCreated(_ notification: Foundation.Notification) {
        if myLikes {
            return;
        }
        
        if let userInfo = notification.userInfo as? Dictionary<String, Post> {
            if let post = userInfo["post"] {
                if (!self.allPosts.contains(post)) {
                    self.allPosts.append(post)
                    postsTableView.reloadData()
                }
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchText = ""
        (self.parent as? HomeViewController)?.removeSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if myLikes {
            setBackButton()
            title = "My Likes"
        }
        self.edgesForExtendedLayout = UIRectEdge()
        postsTableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostTableViewCell")
        postsTableView.separatorStyle     = .none
        postsTableView.estimatedRowHeight = 400
        
        postsTableView.addPullToRefresh { () -> Void in
            
            if self.myLikes {
                self.loadUserLikes(true)
            } else {
                self.loadData(true)
            }
        }
        
        if !self.myLikes {
            postsTableView.addInfiniteScrolling { () -> Void in
                self.loadNextPosts()
            }
        }
        
        
        //Notification.
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.createdNewPost(_:)), name: NSNotification.Name(rawValue: Constants.Notifications.CreatedPost), object: nil)
        
    }
    
    func createdNewPost(_ note: Foundation.Notification) {
        
        if let info = note.userInfo as? Dictionary<String, Post> {
            if let post:Post = info["post"] {
                self.allPosts.insert(post, at: 0)
                self.postsTableView.reloadData()
            }
        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myLikes {
            return likedPosts.count
        } else {
            if searchText != nil && searchText != "" {
                return filteredPosts.count
            } else {
                return allPosts.count
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PostTableViewCell? = postsTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as? PostTableViewCell
        if cell == nil {
            cell = PostTableViewCell()
        }
        
        if myLikes {
            cell?.configureWithPost(likedPosts[indexPath.row], indexPath: indexPath)
        } else {
            if searchText != nil && searchText != "" {
                cell?.configureWithPost(filteredPosts[indexPath.row], indexPath: indexPath)
            } else {
                cell?.configureWithPost(allPosts[indexPath.row], indexPath: indexPath)
            }
        }
        
        cell?.selectionStyle = .none
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self.parent as? HomeViewController)?.hideSearchField()
        let postDetailsVC = PostDetailsViewController()
        if myLikes {
            postDetailsVC.post = likedPosts[indexPath.row]
        } else {
            if searchText != nil && searchText != "" {
                postDetailsVC.post = filteredPosts[indexPath.row]
            } else {
                postDetailsVC.post = allPosts[indexPath.row]
            }
            
        }
        
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
    
    // MARK: PostTableViewCell Delegate.
    func downloadedPostImage(_ indexPath: IndexPath?) {
        postsTableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
    }
    
    func tapUserInfo(_ userInfo: User?) {
        let userView = OtherProfileViewController(userInfo: userInfo)
        navigationController?.pushViewController(userView, animated: true)
    }
    
    func tapURL(_ url: String?) {
        let webVC = WebViewController()
        webVC.siteLink = url
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func tapLike(_ post: Post?, cell: PostTableViewCell?) {
        if !(post?.isLikedByUser)! {
            SVProgressHUD.show(withStatus: "Loading")
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
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            
            SVProgressHUD.show(withStatus: "Loading")
            networkController.deleteLike("\(post!.postId!)", completionHandler: { (error) -> () in
                if error == nil {
                    post?.postNumberOfLikes = (post?.postNumberOfLikes)! - 1
                    post?.isLikedByUser = false
                    cell?.configureWithPost(post!)
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    
    // MARK: Search Posts
    
    func filterResults(_ textToSearch: String) {
        print("Search text: \(textToSearch)")
        print("allPosts: \(allPosts.count)")
        
        filteredPosts.removeAll()
        filteredPosts = allPosts.filter({( post : Post) -> Bool in
            let containInText = (post.postText?.lowercased().contains(textToSearch.lowercased()))!
            let containInTitle = (post.postHeader?.lowercased().contains(textToSearch.lowercased()))!
            var containInTag = false
            
            for t in post.postTopics!  {
                if t.name?.lowercased().contains(textToSearch.lowercased()) == true {
                    containInTag = true
                    break
                }
            }
            return containInText || containInTitle || containInTag
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
    func loadUserLikes(_ pullToRefresh: Bool) {
        
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        networkController.getUserLikes(String(networkController.currentUserId!)) { (likes, error) -> () in
            SVProgressHUD.dismiss()
            if error == nil {
                
                self.isDataLoaded = true
                // build the list of post liked by the user
                self.likedPosts = likes.map({ (actual) -> Post in
                    actual.likePost!
                })
                
                if self.likedPosts.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No content has been posted\n\nwhy don't post someting?")
                }

                self.postsTableView.reloadData()
                self.postsTableView.pullToRefreshView.stopAnimating()
                
            } else {
                self.isDataLoaded = false
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
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                self.postsTableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func loadData(_ pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: 0, sort_by: nil, completionHandler: { (posts, error) -> () in
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
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
            }
            self.postsTableView.pullToRefreshView.stopAnimating()
        })
    }
    
    func deletePost(_ postId: Int) {
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
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: page, sort_by: nil, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.allPosts.append(contentsOf: posts)
                self.postsTableView.reloadData()
                
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
            self.postsTableView.infiniteScrollingView.stopAnimating()
        })
    }
    
    func addTableEmptyMessage(_ message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: postsTableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        postsTableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        postsTableView.backgroundView = nil
    }
}
