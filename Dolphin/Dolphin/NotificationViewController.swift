//
//  NotificationViewController.swift
//  Dolphin
//
//  Created by Joachim on 8/30/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotificationViewController: DolphinViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var contentTableView: UITableView!
    
    let networkController = NetworkController.sharedInstance
    var notifications: [Notification]        = []
    let kPageQuantity: Int = 10
    var page: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.loadData(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        // Do any additional setup after loading the view.
        setBackButton()
        self.title = "Notifications"
        contentTableView.registerNib(UINib(nibName: "NotificationTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "NotificationTableViewCell")
        contentTableView.estimatedRowHeight = 60.0
        contentTableView.rowHeight = UITableViewAutomaticDimension
        contentTableView.addPullToRefreshWithActionHandler { () -> Void in
            self.loadData(true)
        }
        
        contentTableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadNextPosts()
        }
    }
    
    func loadData(pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        
        networkController.filterNotification(nil, quantity: kPageQuantity, page: 0, sort_by: nil) { (notifications, error) in
            if error == nil {
                self.notifications = notifications
                if self.notifications.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No Notifications.")
                }
                self.contentTableView.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                
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
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
            }
            self.contentTableView.pullToRefreshView.stopAnimating()
        }
    }
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterNotification(nil, quantity: kPageQuantity, page: page, sort_by: nil) { (notifications, error) in
            if error == nil {
                self.notifications.appendContentsOf(notifications)
                self.contentTableView.reloadData()
                
                
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
            self.contentTableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    func addTableEmptyMessage(message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: contentTableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .Center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        contentTableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        contentTableView.backgroundView = nil
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: NotificationTableViewCell? = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell") as? NotificationTableViewCell
        if cell == nil {
            cell = NotificationTableViewCell()
        }
        
        cell?.configureCell(notifications[indexPath.row])
        cell?.selectionStyle = .None
//        cell?.delegate = self
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        
        if let post = notification.post {
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = post
            postDetailsVC.needToReloadPost = true
            self.navigationController!.pushViewController(postDetailsVC, animated: true)
            
            return
        }
        else if let pod = notification.pod {
            let podDetailsVC = PODDetailsViewController()
            podDetailsVC.pod = pod
            podDetailsVC.needToReloadPod = true
            self.navigationController!.pushViewController(podDetailsVC, animated: true)
            
            return
        }

    }

}
