//
//  PopularViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class PopularViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PostTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let networkController = NetworkController.sharedInstance
    
    var topics: [Topic]        = []
    var filteredTopics:[Topic] = []
    var pods: [POD]             = []
    var filteredPods: [POD]     = []
    
    var posts: [Post]           = []
    var filteredPosts: [Post]   = []
    var searchText: String?     = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        (parentViewController as? HomeViewController)?.removeRightButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        
        tableView.registerNib(UINib(nibName: "PopularTrendingTopicsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PopularTrendingTopicsTableViewCell")
        tableView.registerNib(UINib(nibName: "PopularPODsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PopularPODsTableViewCell")
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 400

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postRemoved(_:)) , name: Constants.Notifications.DeletedPost, object: nil)
        loadData()
    }
    
    func postRemoved(notification: NSNotification) {
        if let userInfo = notification.userInfo as? Dictionary<String, Post> {
            if let post = userInfo["post"] {
                var index = 0;
                
                for item in self.posts {
                    if item.postId == post.postId {
                        self.posts.removeAtIndex(index)
                        break
                    }
                    
                    index += 1
                }
                
                index = 0;
                for item in self.filteredPosts {
                    if item.postId == post.postId {
                        self.filteredPosts.removeAtIndex(index)
                        break
                    }
                    
                    index += 1
                }
                
                self.tableView.reloadData()
            }
        }
    }

    func loadData() {
        
        SVProgressHUD.showWithStatus("Loading")
        //Load Topic.
        networkController.filterTopic(nil, quantity: Constants.Popular.Topic_Limit, page: 0, sort_by: "posts_count") { (topics, error) -> () in 
            
            if error == nil {
                self.topics = topics
            } else {
                
            }
            
            //Load Popular Pods.
            self.networkController.filterPOD(nil, userId: nil, fromDate: nil, toDate: nil, quantity: Constants.Popular.Pod_Limit, page: 0, sort_by: "users_count") { (pods, error) -> () in
                if error == nil {
                    self.pods = pods
                } else {
                    
                }
                
                //Load Popular Posts.
                self.networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: Constants.Popular.Post_Limit, page: 0, sort_by: "likes_count", completionHandler: { (posts, error) -> () in
                    if error == nil {
                        self.posts = posts
                    } else {
                    }
                    
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1{
            return 1
        } else {
            if searchText != nil && searchText != "" {
                return filteredPosts.count
            } else {
                return posts.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("PopularTrendingTopicsTableViewCell") as? PopularTrendingTopicsTableViewCell
            if cell == nil {
                cell = PopularTrendingTopicsTableViewCell()
            }
            (cell as? PopularTrendingTopicsTableViewCell)!.configureWithDataSource(self, delegate: self, centerAligned: true)
            (cell as? PopularTrendingTopicsTableViewCell)!.collectionView.reloadData()
            
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("PopularPODsTableViewCell") as? PopularPODsTableViewCell
            if cell == nil {
                cell = PopularPODsTableViewCell()
            }
            (cell as? PopularPODsTableViewCell)!.configureWithDataSource(self, delegate: self)
            (cell as? PopularPODsTableViewCell)!.podsCollectionView.reloadData()
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
            if cell == nil {
                cell = PostTableViewCell()
            }
            
            if searchText != nil && searchText != "" {
                (cell as? PostTableViewCell)!.configureWithPost(filteredPosts[indexPath.row], indexPath: indexPath)
            } else {
                (cell as? PostTableViewCell)!.configureWithPost(posts[indexPath.row], indexPath: indexPath)
            }
            (cell as? PostTableViewCell)!.delegate = self
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            return self.view.frame.size.width / 3
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = self.view.backgroundColor
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.textAlignment = .Center
        headerLabel.font = UIFont(name: Constants.Fonts.Raleway_Bold, size: 11.0)
        headerLabel.textColor = UIColor(red: 83.0/255.0, green: 83.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        if section == 0 {
            headerLabel.text = "BIG WAVES"
        } else if section == 1 {
            headerLabel.text = "POPULAR PODS"
        } else if section == 2 {
            headerLabel.text = "POPULAR POSTS"
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of comment cells
        if indexPath.section == 1 {
            cell.selectionStyle = .None
        }
    }
    
    // MARK: - Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            (self.parentViewController as? HomeViewController)?.hideSearchField()
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = posts[indexPath.row]
            navigationController?.pushViewController(postDetailsVC, animated: true)
        }
    }
    
    // MARK: - CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            if searchText != nil && searchText != "" {
                return filteredTopics.count
            } else {
                return topics.count
            }

        } else if collectionView.tag == 1 {
            if searchText != nil && searchText != "" {
                return filteredPods.count
            } else {
                return pods.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("TopicCollectionViewCell", forIndexPath: indexPath) as? TopicCollectionViewCell
            if cell == nil {
                cell = TopicCollectionViewCell()
            }
            
            if searchText != nil && searchText != "" {
                cell?.configureWithName(filteredTopics[indexPath.row].name!.uppercaseString, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
            } else {
                cell?.configureWithName(topics[indexPath.row].name!.uppercaseString, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
            }
            return cell!
        } else {
            var cell: PODCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("PODCollectionViewCell", forIndexPath: indexPath) as? PODCollectionViewCell
            if cell == nil {
                cell = PODCollectionViewCell()
            }
            
            if searchText != nil && searchText != "" {
                cell?.configureWithPOD(filteredPods[indexPath.row])
            } else {
                cell?.configureWithPOD(pods[indexPath.row])
            }

            return cell!
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let text = topics[indexPath.row].name!.uppercaseString
            let font = UIFont.systemFontOfSize(16)
            let textString = text as NSString
            
            let textAttributes = [NSFontAttributeName: font]
            var size = textString.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 20, 35), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil).size
            if size.width < self.view.frame.size.width / 4 {
                size = CGSize(width: self.view.frame.size.width / 4, height: size.height)
            }
            return size
        } else {
            return CGSize(width: self.view.frame.size.width / 3.8, height: self.view.frame.size.width / 3.8)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    // MARK: - CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.tag == 0 {
            let topic = topics[indexPath.row]
            let topicPost = TagPostsViewController(likes: false)
            topicPost.selectedTopic = topic
            navigationController?.pushViewController(topicPost, animated: true)

        } else if collectionView.tag == 1 {
            print("Pod %@ pressed", pods[indexPath.row].name)
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = pods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            navigationController?.pushViewController(podDetailsVC, animated: true)
        }
    }

    // MARK: PostTableViewCell Delegate.
    func downloadedPostImage(indexPath: NSIndexPath?) {
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func tapUserInfo(userInfo: User?) {
        let userView = OtherProfileViewController(userInfo: userInfo)
        navigationController?.pushViewController(userView, animated: true)
    }
    
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
        filteredPosts.removeAll()
        filteredPosts = posts.filter({( post : Post) -> Bool in
            let containInText = (post.postText?.lowercaseString.containsString(textToSearch.lowercaseString))!
            let containInTitle = (post.postHeader?.lowercaseString.containsString(textToSearch.lowercaseString))!
            var containInTag = false
            
            for t in post.postTopics!  {
                if t.name?.lowercaseString.containsString(textToSearch.lowercaseString) == true {
                    containInTag = true
                    break
                }
            }
            return containInText || containInTitle || containInTag
        })
        
        filteredPods.removeAll()
        filteredPods = pods.filter({( pod : POD) -> Bool in
            
            let containInName = (pod.name?.lowercaseString.containsString(textToSearch.lowercaseString))!
            let containInDescription = (pod.descriptionText?.lowercaseString.containsString(textToSearch.lowercaseString))!
            return containInName || containInDescription
        })
        
        filteredTopics.removeAll()
        filteredTopics = topics.filter({( topic : Topic) -> Bool in
            return (topic.name!.lowercaseString.containsString(textToSearch.lowercaseString))
        })

        searchText = textToSearch
        tableView.reloadData()
    }
    
    func userDidCancelSearch() {
        print("User cancelled search")
        searchText = ""
        tableView.reloadData()
    }
}
