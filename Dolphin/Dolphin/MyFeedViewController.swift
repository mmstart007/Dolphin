//
//  MyFeedViewController.swift
//  Dolphin
//
//  Created by Joachim on 5/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyFeedViewController: FeedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func loadData(pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        
        networkController.filterMyFeedsPost(kPageQuantity, page: 0, completionHandler: { (posts, error) -> () in
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
    
    override func loadNextPosts() {
        page = page + 1
        networkController.filterMyFeedsPost(kPageQuantity, page: page, completionHandler: { (posts, error) -> () in
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

}
