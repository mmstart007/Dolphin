//
//  PODsListViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class PODsListViewController : UIViewController, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 10
    
    @IBOutlet weak var allPODstableView: UITableView!
    @IBOutlet weak var myPODsCollectionView: UICollectionView!
    var segmentedControl: UISegmentedControl!
    
    
    var allPods: [POD]      = []
    var myPods: [POD]       = []
    var filteredPODs: [POD] = []
    var searchText: String? = nil
    var isDataLoaded: Bool  = false
    var page: Int           = 0
    
    required init() {
        super.init(nibName: "PODsListViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newPodCreated:" , name: Constants.Notifications.CreatedPod, object: nil)
        
        allPODstableView.registerNib(UINib(nibName: "PODPreviewTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODPreviewTableViewCell")
        myPODsCollectionView.registerNib(UINib(nibName: "MyPODPreviewCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "MyPODPreviewCollectionViewCell")
        myPODsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        allPODstableView.separatorStyle = .None
        myPODsCollectionView.dataSource = self
        myPODsCollectionView.delegate   = self
        
        segmentedControl = UISegmentedControl(items: ["All PODs", "My PODs"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        allPODstableView.estimatedRowHeight = 206
        allPODstableView.addPullToRefreshWithActionHandler { () -> Void in
            self.loadData(true)
        }
        
        allPODstableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadNextPODs()
        }
        loadData(false)
    }
    
    func refreshView() {
        loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        if segmentedControl.selectedSegmentIndex == 0 {
            allPODstableView.reloadData()
        } else {
            myPODsCollectionView.reloadData()
        }
        let parent = self.parentViewController as? HomeViewController
        if (searchText == nil || searchText == "") {
            parent?.removeSearchBar()
            parent?.setSearchRightButton()
            self.parentViewController?.navigationItem.titleView = segmentedControl
        } else {
            parent?.searchBar?.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchText = ""
        self.parentViewController?.navigationItem.titleView = nil
    }
    
    func newPodCreated(notification: NSNotification) {
        if let userInfo = notification.userInfo as? Dictionary<String, POD> {
            if let pod = userInfo["pod"] {
                if (!self.allPods.contains(pod)) {
                    self.allPods.insert(pod, atIndex: 0)
                }
                
                if (!self.myPods.contains(pod)) {
                    self.myPods.insert(pod, atIndex: 0)
                }
                
                self.allPODstableView.reloadData()
                self.myPODsCollectionView.reloadData()
            }
        }
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        if segmentedControl.selectedSegmentIndex == 0 {
            allPODstableView.hidden     = false
            myPODsCollectionView.hidden = true
        } else {
            allPODstableView.hidden     = true
            myPODsCollectionView.hidden = false
        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText != nil && searchText != "" {
            return filteredPODs.count
        } else {
            return allPods.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PODPreviewTableViewCell? = tableView.dequeueReusableCellWithIdentifier("PODPreviewTableViewCell") as? PODPreviewTableViewCell
        if cell == nil {
            cell = PODPreviewTableViewCell()
        }
        if searchText != nil && searchText != "" {
            cell?.configureWithPOD(filteredPODs[indexPath.row])
        } else {
            cell?.configureWithPOD(allPods[indexPath.row])
        }
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if searchText != nil && searchText != "" {
            (cell as? PODPreviewTableViewCell)!.addUserImages(filteredPODs[indexPath.row])
        } else {
            (cell as? PODPreviewTableViewCell)!.addUserImages(allPods[indexPath.row])
        }
        cell.updateConstraintsIfNeeded()
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("POD selected: " + String(indexPath.row))
        
        if (searchText == nil || searchText == "") {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = allPods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.prevViewController = self
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.prevViewController = self
            podDetailsVC.prevViewController = self
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        }
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchText != nil && searchText != "" {
            return filteredPODs.count
        } else {
            return myPods.count + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: MyPODPreviewCollectionViewCell? = myPODsCollectionView.dequeueReusableCellWithReuseIdentifier("MyPODPreviewCollectionViewCell", forIndexPath: indexPath) as? MyPODPreviewCollectionViewCell
        if cell == nil {
            cell = MyPODPreviewCollectionViewCell()
        }
        if searchText != nil && searchText != "" {
            cell!.configureWithPOD(filteredPODs[indexPath.row])
        } else {
            if indexPath.row > 0 {
                cell!.configureWithPOD(myPods[indexPath.row - 1])
            } else {
                cell?.configureWithPOD(nil)
            }
        }
        
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        (self.parentViewController as? HomeViewController)?.hideSearchField()
        if (searchText == nil || searchText == "") && indexPath.row == 0 {
            let createPODVC = CreatePodViewController()
            navigationController?.pushViewController(createPODVC, animated: true)
        } else if (searchText == nil || searchText == ""){
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = allPods[indexPath.row - 1]
            podDetailsVC.pod = selectedPOD
            navigationController?.pushViewController(podDetailsVC, animated: true)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
            navigationController?.pushViewController(podDetailsVC, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let cellSize = CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)
        return cellSize
//        if (searchText == nil || searchText == "") && indexPath.row == 0 {
//            return cellSize
//        } else if (searchText == nil || searchText == ""){
//            let selectedPOD = allPods[indexPath.row - 1]
//            return self.getCellSize(selectedPOD)
//        } else {
//            let selectedPOD = filteredPODs[indexPath.row]
//            return self.getCellSize(selectedPOD)
//        }
    }
    
    func getCellSize(pod: POD) -> CGSize {
        let cellSize = CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)
        
        let image_width = CGFloat(pod.image_width!)
        let image_height = CGFloat(pod.image_height!)
        
        if image_width == 0 || image_height == 0 {
            return cellSize
        } else {
            let real_width = cellSize.width
            let real_height = real_width * image_height / image_width
            
            return CGSizeMake(real_width, real_height)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: Search Posts
    
    func filterResults(textToSearch: String) {
        print("Search text: \(textToSearch)")
        
        searchText = textToSearch
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredPODs = allPods.filter({( pod : POD) -> Bool in
                return (pod.name!.lowercaseString.containsString(textToSearch.lowercaseString))
            })
            allPODstableView.reloadData()
        } else {
            filteredPODs = myPods.filter({( pod : POD) -> Bool in
                return (pod.name!.lowercaseString.containsString(textToSearch.lowercaseString))
            })
            myPODsCollectionView.reloadData()
        }
    }
    
    func userDidCancelSearch() {
        print("User cancelled search")
        searchText = ""
        if segmentedControl.selectedSegmentIndex == 0 {
            allPODstableView.reloadData()
        } else {
            myPODsCollectionView.reloadData()
        }
        self.parentViewController?.navigationItem.titleView = segmentedControl
    }
    
    // MARK: - Auxiliary methods
    
    func checkPrivatePODs(goToViewController: UIViewController, pod: POD?) {
        if pod != nil {
            var isMember = false
            for user in (pod?.users)! {
                if user.id == networkController.currentUserId {
                    isMember = true
                    break
                }
            }
            
            if pod!.isPrivate == 1 && pod?.owner?.id != networkController.currentUserId && !isMember {
                let alert = UIAlertController(title: "Access", message: "This is a PRIVATE POD, do you want to request access to it?", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Request", style: UIAlertActionStyle.Default, handler: { action in
                    SVProgressHUD.show()
                    self.networkController.joinPodMember(String(pod!.id!), completionHandler: { (error) in
                        SVProgressHUD.dismiss()
                        if error == nil {
                            Utils.presentAlertMessage("Success", message: "Request Sent", cancelActionText: "Ok", presentingViewContoller: self)
                        } else {
                            Utils.presentAlertMessage("Error", message: "Error sending request", cancelActionText: "Ok", presentingViewContoller: self)
                        }
                    })
                    
                }))
                alert.addAction(UIAlertAction(title: "Not now", style: UIAlertActionStyle.Cancel, handler: nil))
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(goToViewController, animated: true)
            }
            
        }
    }
    
    func loadData(pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        networkController.filterPOD(nil, userId: nil, fromDate: nil, toDate: nil, quantity: kPageQuantity, page: 0, sort_by: nil) { (pods, error) -> () in
            
            if error == nil {
                
                self.allPods = pods
                if self.allPods.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No PODs has been created\n\nwhy don't create a POD?")
                }
                self.allPODstableView.reloadData()
                
                // load mypods info
                self.loadMyData(pullToRefresh)
                
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
                self.allPODstableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func loadNextPODs() {
        page = page + 1
        networkController.filterPOD(nil, userId: nil, fromDate: nil, toDate: nil, quantity: kPageQuantity, page: page, sort_by: nil) {  (pods, error) -> () in
            if error == nil {
                self.allPods.appendContentsOf(pods)
                self.allPODstableView.reloadData()
                
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
            self.allPODstableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    func loadMyData(pullToRefresh: Bool) {
        if !pullToRefresh {
            SVProgressHUD.showWithStatus("Loading")
        }
        networkController.filterPOD(nil, userId: networkController.currentUserId, fromDate: nil, toDate: nil, quantity: 100, page: 0, sort_by: nil) { (pods, error) -> () in
            
            if error == nil {
                self.isDataLoaded = true
                self.myPods = pods
                
                self.myPODsCollectionView.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                } else {
                    self.allPODstableView.pullToRefreshView.stopAnimating()
                }
                
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
                self.allPODstableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func addTableEmptyMessage(message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: allPODstableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .Center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        allPODstableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        allPODstableView.backgroundView = nil
    }
    
}
