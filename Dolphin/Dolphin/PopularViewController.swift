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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        (parentViewController as? HomeViewController)?.removeRightButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        tableView.register(UINib(nibName: "PopularTrendingTopicsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PopularTrendingTopicsTableViewCell")
        tableView.register(UINib(nibName: "PopularPODsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PopularPODsTableViewCell")
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostTableViewCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 400

        NotificationCenter.default.addObserver(self, selector: #selector(postRemoved(_:)) , name: NSNotification.Name(rawValue: Constants.Notifications.DeletedPost), object: nil)
        loadData()
    }
    
    func postRemoved(_ notification: Foundation.Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, Post> {
            if let post = userInfo["post"] {
                var index = 0;
                
                for item in self.posts {
                    if item.postId == post.postId {
                        self.posts.remove(at: index)
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
                
                self.tableView.reloadData()
            }
        }
    }

    func loadData() {
        
        SVProgressHUD.show(withStatus: "Loading")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PopularTrendingTopicsTableViewCell") as? PopularTrendingTopicsTableViewCell
            if cell == nil {
                cell = PopularTrendingTopicsTableViewCell()
            }
            (cell as? PopularTrendingTopicsTableViewCell)!.configureWithDataSource(self, delegate: self, centerAligned: true)
            (cell as? PopularTrendingTopicsTableViewCell)!.collectionView.reloadData()
            
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PopularPODsTableViewCell") as? PopularPODsTableViewCell
            if cell == nil {
                cell = PopularPODsTableViewCell()
            }
            (cell as? PopularPODsTableViewCell)!.configureWithDataSource(self, delegate: self)
            (cell as? PopularPODsTableViewCell)!.podsCollectionView.reloadData()
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as? PostTableViewCell
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
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            return self.view.frame.size.width / 3
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = self.view.backgroundColor
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textAlignment = .center
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Adjust views of comment cells
        if indexPath.section == 1 {
            cell.selectionStyle = .none
        }
    }
    
    // MARK: - Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            (self.parent as? HomeViewController)?.hideSearchField()
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = posts[indexPath.row]
            navigationController?.pushViewController(postDetailsVC, animated: true)
        }
    }
    
    // MARK: - CollectionView Datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicCollectionViewCell", for: indexPath) as? TopicCollectionViewCell
            if cell == nil {
                cell = TopicCollectionViewCell()
            }
            
            if searchText != nil && searchText != "" {
                cell?.configureWithName(filteredTopics[indexPath.row].name!.uppercased(), color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
            } else {
                cell?.configureWithName(topics[indexPath.row].name!.uppercased(), color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
            }
            return cell!
        } else {
            var cell: PODCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "PODCollectionViewCell", for: indexPath) as? PODCollectionViewCell
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let text = topics[indexPath.row].name!.uppercased()
            let font = UIFont.systemFont(ofSize: 16)
            let textString = text as NSString
            
            let textAttributes = [NSFontAttributeName: font]
            var size = textString.boundingRect(with: CGSize(width: self.view.frame.size.width - 20, height: 35), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).size
            if size.width < self.view.frame.size.width / 4 {
                size = CGSize(width: self.view.frame.size.width / 4, height: size.height)
            }
            return size
        } else {
            return CGSize(width: self.view.frame.size.width / 3.8, height: self.view.frame.size.width / 3.8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    // MARK: - CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            let topic = topics[indexPath.row]
            let topicPost = TagPostsViewController(likes: false)
            topicPost.selectedTopic = topic
            navigationController?.pushViewController(topicPost, animated: true)

        } else if collectionView.tag == 1 {
            print("Pod %@ pressed", pods[indexPath.row].name!)
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = pods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            navigationController?.pushViewController(podDetailsVC, animated: true)
        }
    }

    // MARK: PostTableViewCell Delegate.
    func downloadedPostImage(_ indexPath: IndexPath?) {
        tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
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
        filteredPosts.removeAll()
        filteredPosts = posts.filter({( post : Post) -> Bool in
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
        
        filteredPods.removeAll()
        filteredPods = pods.filter({( pod : POD) -> Bool in
            
            let containInName = (pod.name?.lowercased().contains(textToSearch.lowercased()))!
            let containInDescription = (pod.descriptionText?.lowercased().contains(textToSearch.lowercased()))!
            return containInName || containInDescription
        })
        
        filteredTopics.removeAll()
        filteredTopics = topics.filter({( topic : Topic) -> Bool in
            return (topic.name!.lowercased().contains(textToSearch.lowercased()))
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
