//
//  MyFeedViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 5/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class TagPostsViewController: FeedViewController {
    
    var selectedTopic: Topic?
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        title = selectedTopic?.name
        
        topics.append(self.selectedTopic!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func loadData(_ pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        
        networkController.filterPost(topics, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: 0, podId: nil, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
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
    
    override func loadNextPosts() {
        page = page + 1
        networkController.filterPost(topics, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: page, podId: nil, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
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
    
}
