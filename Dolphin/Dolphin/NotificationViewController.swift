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
        contentTableView.register(UINib(nibName: "NotificationTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotificationTableViewCell")
        contentTableView.estimatedRowHeight = 60.0
        contentTableView.rowHeight = UITableViewAutomaticDimension
        contentTableView.addPullToRefresh { () -> Void in
            self.loadData(true)
        }
        
        contentTableView.addInfiniteScrolling { () -> Void in
            self.loadNextPosts()
        }
    }
    
    func loadData(_ pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
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
            self.contentTableView.pullToRefreshView.stopAnimating()
        }
    }
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterNotification(nil, quantity: kPageQuantity, page: page, sort_by: nil) { (notifications, error) in
            if error == nil {
                self.notifications.append(contentsOf: notifications)
                self.contentTableView.reloadData()
                
                
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
            self.contentTableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    func addTableEmptyMessage(_ message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: contentTableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        contentTableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        contentTableView.backgroundView = nil
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: NotificationTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as? NotificationTableViewCell
        if cell == nil {
            cell = NotificationTableViewCell()
        }
        
        cell?.configureCell(notifications[indexPath.row])
        cell?.selectionStyle = .none
//        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
    // MARK: Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
