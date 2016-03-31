//
//  PODDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/15/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class PODDetailsViewController: DolphinViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewPosts: UITableView!
    let networkController = NetworkController.sharedInstance
    var pod: POD?
    
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
            return networkController.posts.count
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
            cell?.configureWithPost(networkController.posts[indexPath.row])
            
            cell?.selectionStyle = .None
            return cell!
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    // MARK: - Actions
    
    func plusButtonTouchUpInside() {
        let createPODVC = CreatePodViewController()
        navigationController?.pushViewController(createPODVC, animated: true)
    }
    
}
