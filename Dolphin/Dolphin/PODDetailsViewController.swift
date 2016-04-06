//
//  PODDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/15/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class PODDetailsViewController: DolphinViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewPosts: UITableView!
    @IBOutlet weak var actionMenuBackground: UIView!
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 10
    
    var pod: POD?
    var postOfPOD: [Post] = []
    var actionMenu: UIView? = nil
    var page: Int = 0
    
    required init() {
        super.init(nibName: "PODDetailsViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        registerCells()
        
        // setup delegate and datesource
        tableViewPosts.delegate           = self
        tableViewPosts.dataSource         = self
        tableViewPosts.separatorStyle     = .None
        tableViewPosts.estimatedRowHeight = 400
        tableViewPosts.backgroundColor    = UIColor.lightGrayBackground()
        
        tableViewPosts.addPullToRefreshWithActionHandler { () -> Void in
            self.loadData(true)
        }
        
        tableViewPosts.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadNextPosts()
        }
        
        // Add bottom blue bar
        let fakeTabBar = UIView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height - 113, width: UIScreen.mainScreen().bounds.size.width, height: 49))
        fakeTabBar.backgroundColor = UIColor.blueDolphin()
        
        // Add plus button
        let plusButton = UIButton(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width / 2.0) - 40, y: UIScreen.mainScreen().bounds.size.height - 130, width: 80, height: 80))
        plusButton.enabled = true
        plusButton.layer.cornerRadius = 40
        plusButton.layer.borderColor = UIColor.whiteColor().CGColor
        plusButton.layer.borderWidth = 3
        plusButton.setImage(UIImage(named: "TabbarPlusIcon"), forState: .Normal)
        plusButton .addTarget(self , action: "plusButtonTouchUpInside", forControlEvents: .TouchUpInside)
        plusButton.backgroundColor = UIColor.blueDolphin()
        self.view.addSubview(fakeTabBar)
        self.view.addSubview(plusButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewPosts.reloadData()
        loadData(false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation bar
    
    func setupNavigationBar() {
        setBackButton()
        title = pod?.name
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewPosts.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        tableViewPosts.registerNib(UINib(nibName: "PODMembersTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODMembersTableViewCell")
    }
    
    // MARK: - TableView datasource
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Only header for comments section
        if section == 0 {
            return 25
        } else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Only header for comments section
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
            headerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 25))
            headerLabel.text = "Members"
            headerLabel.textColor = UIColor.grayColor()
            headerLabel.font = headerLabel.font.fontWithSize(11)
            headerView.addSubview(headerLabel)
            return headerView
        } else {
            return UIView()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1;
        } else {
            return postOfPOD.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableViewPosts.dequeueReusableCellWithIdentifier("PODMembersTableViewCell") as? PODMembersTableViewCell
            if cell == nil {
                cell = PODMembersTableViewCell()
            }
            cell?.configureWithPOD(pod!)
            
            cell?.selectionStyle = .None
            return cell!
            
        } else {
            var cell = tableViewPosts.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
            if cell == nil {
                cell = PostTableViewCell()
            }
            cell?.configureWithPost(postOfPOD[indexPath.row])
            
            cell?.selectionStyle = .None
            return cell!
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    // MARK: - TableView delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = postOfPOD[indexPath.row]
            navigationController?.pushViewController(postDetailsVC, animated: true)
        }
    }
    
    // MARK: - Plus button Actions
    
    func plusButtonTouchUpInside() {
        
        print("Plus button pressed")
        let subViewsArray = NSBundle.mainBundle().loadNibNamed("NewPostMenu", owner: self, options: nil)
        self.actionMenu = subViewsArray[0] as? UIView
        actionMenuBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "actionMenuBackgroundTapped"))
        self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
        UIApplication.sharedApplication().keyWindow?.addSubview(actionMenu!)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenu?.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenuBackground.alpha = 0.4
                })
        }
    }
    
    @IBAction func closeNewPostViewButtonTouchUpInside(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenuBackground.alpha = 0
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
                    }) { (finished) -> Void in
                        self.actionMenu?.removeFromSuperview()
                }
        }
    }
    
    @IBAction func postLinkButtonTouchUpInside(sender: AnyObject) {
        let createLinkPostVC = CreateURLPostViewController()
        createLinkPostVC.podId = pod?.id
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post link button pressed")
        
    }
    @IBAction func postPhotoButtonTouchUpInside(sender: AnyObject) {
        
        let createImagePostVC = CreateImagePostViewController()
        createImagePostVC.podId = pod?.id
        navigationController?.pushViewController(createImagePostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post photo button pressed")
        
    }
    @IBAction func postTextButtonTouchUpInside(sender: AnyObject) {
        closeNewPostViewButtonTouchUpInside(self)
        let createTextPostVC = CreateTextPostViewController()
        createTextPostVC.podId = pod?.id
        let textPostNavController = UINavigationController(rootViewController: createTextPostVC)
        presentViewController(textPostNavController, animated: true, completion: nil)
        print("Post text button pressed")
        
    }
    
    func actionMenuBackgroundTapped() {
        // Overlay was tapped, so we close the new post view
        closeNewPostViewButtonTouchUpInside(self)
    }
    
    // MARK: - Network
    
    func loadData(pullToRefresh: Bool) {
        page = 0
        tableViewPosts.showsInfiniteScrolling = true
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId:  nil, quantity: kPageQuantity, page: 0, podId: pod?.id, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.postOfPOD = posts
                if self.postOfPOD.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No content has been posted\n\nwhy don't post something?")
                }
                self.tableViewPosts.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                } else {
                    self.tableViewPosts.pullToRefreshView.stopAnimating()
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
                self.tableViewPosts.pullToRefreshView.stopAnimating()
            }
        })
    }
    
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: page, podId: pod?.id, completionHandler: { (posts, error) -> () in
            if error == nil {
                if posts.count > 0 {
                    self.postOfPOD.appendContentsOf(posts)
                    self.tableViewPosts.reloadData()
                } else {
                    // remove the infinite scrolling because we don't have more elements
                    self.tableViewPosts.showsInfiniteScrolling = false
                }
                
                
            } else {
                // decrease the page
                self.page = self.page - 1
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
            self.tableViewPosts.infiniteScrollingView.stopAnimating()
        })
    }
    
    func addTableEmptyMessage(message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: tableViewPosts.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .Center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        tableViewPosts.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        tableViewPosts.backgroundView = nil
    }
    
    
    
}
