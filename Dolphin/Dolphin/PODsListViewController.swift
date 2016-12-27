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

protocol UpdateProtocol {
    func updatePodUI()
}


class PODsListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UpdateProtocol {
    
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
    var podSelected : POD?
    var isFillter: Bool  = false
    
    required init() {
        super.init(nibName: "PODsListViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newPodCreated(_:)) , name: NSNotification.Name(rawValue: Constants.Notifications.CreatedPod), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(podRemoved(_:)) , name: NSNotification.Name(rawValue: Constants.Notifications.DeletedPod), object: nil)
        
        allPODstableView.register(UINib(nibName: "PODPreviewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PODPreviewTableViewCell")
        myPODsCollectionView.register(UINib(nibName: "MyPODPreviewCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MyPODPreviewCollectionViewCell")
        myPODsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        allPODstableView.separatorStyle = .none
        myPODsCollectionView.dataSource = self
        myPODsCollectionView.delegate   = self
        
        segmentedControl = UISegmentedControl(items: ["All PODs", "My PODs"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: UIControlEvents.valueChanged)
        
        allPODstableView.estimatedRowHeight = 206
        allPODstableView.addPullToRefresh { () -> Void in
            self.loadData(true)
        }
        
        allPODstableView.addInfiniteScrolling { () -> Void in
            self.loadNextPODs()
        }
        loadData(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if segmentedControl.selectedSegmentIndex == 0 {
            allPODstableView.reloadData()
        } else {
            myPODsCollectionView.reloadData()
        }
        let parent = self.parent as? HomeViewController
        if (searchText == nil || searchText == "") {
            parent?.removeSearchBar()
            parent?.setSearchRightButton()
            self.parent?.navigationItem.titleView = segmentedControl
        } else {
            parent?.searchBar?.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchText = ""
        self.parent?.navigationItem.titleView = nil
    }
    
    func updatePodUI() {
        //
        networkController.getPOD(podSelected!.id!, completionHandler: { (pod, error) -> () in
            if error == nil {
                if pod?.id != nil {
                    //pod?.total_unread = 2;
                    // everything worked ok
                    var resultPod = self.allPods.filter{ $0.id == pod!.id}
                    if(resultPod.count > 0)
                    {
                        self.allPods.filter{ $0.id == pod!.id}[0].total_unread = pod?.total_unread;
                    }
                    
                    resultPod = self.myPods.filter{ $0.id == pod!.id}
                    if(resultPod.count > 0)
                    {
                        self.myPods.filter{ $0.id == pod!.id}[0].total_unread = pod?.total_unread;
                    }
                    
                    self.allPODstableView.reloadData();
                    self.myPODsCollectionView.reloadData();
                } else {
                    // there was an error saving the post
                }
                SVProgressHUD.dismiss()
                
            } else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                var alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    func deletedPod(_ pod: POD) {
        var index = 0;
        for item in allPods {
            if item.id == pod.id {
                allPods.remove(at: index)
                break
            }
            index += 1
        }
        
        index = 0;
        for item in myPods {
            if item.id == pod.id {
                myPods.remove(at: index)
                break
            }
            index += 1
        }
        
        allPODstableView.reloadData()
        myPODsCollectionView.reloadData()
    }
    
    func updatedPod(_ pod: POD) {
        var index = 0;
        for item in allPods {
            if item.id == pod.id {
                allPods[index] = pod
                break
            }
            
            index += 1
        }
        
        index = 0;
        for item in myPods {
            if item.id == pod.id {
                myPods[index] = pod
                break
            }
            index += 1
        }
        
        allPODstableView.reloadData()
        myPODsCollectionView.reloadData()
    }
    
    func refreshView() {
        loadData(false)
    }
    
    func newPodCreated(_ notification: Foundation.Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, POD> {
            if let pod = userInfo["pod"] {
                if (!self.allPods.contains(pod)) {
                    self.allPods.insert(pod, at: 0)
                }
                
                if (!self.myPods.contains(pod)) {
                    self.myPods.insert(pod, at: 0)
                }
                
                self.allPODstableView.reloadData()
                self.myPODsCollectionView.reloadData()
            }
        }
    }
    
    func podRemoved(_ notification: Foundation.Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, POD> {
            if let pod = userInfo["pod"] {
                var index = 0;
                
                for item in self.allPods {
                    if item.id == pod.id {
                        self.allPods.remove(at: index)
                        break
                    }
                    
                    index += 1
                }
                
                
                for item in self.myPods {
                    if item.id == pod.id {
                        self.myPods.remove(at: index)
                        break
                    }
                    
                    index += 1
                }
                
                self.allPODstableView.reloadData()
                self.myPODsCollectionView.reloadData()
            }
        }
    }
    
    // MARK: Segmented Control
    
    func segmentedControlChanged(_ event: UIEvent) {
        print("Event changed to \(segmentedControl.selectedSegmentIndex)")
        if segmentedControl.selectedSegmentIndex == 0 {
            allPODstableView.isHidden     = false
            myPODsCollectionView.isHidden = true
            allPODstableView.reloadData()

        } else {
            allPODstableView.isHidden     = true
            myPODsCollectionView.isHidden = false
            myPODsCollectionView.reloadData()

        }
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText != nil && searchText != "" {
            return filteredPODs.count
        } else {
            return allPods.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PODPreviewTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "PODPreviewTableViewCell") as? PODPreviewTableViewCell
        if cell == nil {
            cell = PODPreviewTableViewCell()
        }
        if searchText != nil && searchText != "" {
            cell?.configureWithPOD(filteredPODs[indexPath.row])
        } else {
            cell?.configureWithPOD(allPods[indexPath.row])
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if searchText != nil && searchText != "" {
            (cell as? PODPreviewTableViewCell)!.addUserImages(filteredPODs[indexPath.row])
        } else {
            (cell as? PODPreviewTableViewCell)!.addUserImages(allPods[indexPath.row])
        }
        cell.updateConstraintsIfNeeded()
    }
    
    // MARK: Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("POD selected: " + String(indexPath.row))
        
        if (searchText == nil || searchText == "") {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = allPods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.prevViewController = self
            podDetailsVC.pListener = self
            self.podSelected = selectedPOD;
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.prevViewController = self
            podDetailsVC.prevViewController = self
            podDetailsVC.pListener = self
            self.podSelected = selectedPOD;
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        }
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchText != nil && searchText != "" {
            return filteredPODs.count
        } else {
            return myPods.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: MyPODPreviewCollectionViewCell? = myPODsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPODPreviewCollectionViewCell", for: indexPath) as? MyPODPreviewCollectionViewCell
        if cell == nil {
            cell = MyPODPreviewCollectionViewCell()
        }
        if searchText != nil && searchText != "" {
            cell!.configureWithPOD(filteredPODs[indexPath.row])
        } else {
            if indexPath.row > 0 {
                cell!.configureWithPOD(myPods[indexPath.row - 1])
                cell?.setNeedsLayout()
                cell?.layoutIfNeeded()
            } else {
                cell?.configureWithPOD(nil)
                cell?.setNeedsLayout()
                cell?.layoutIfNeeded()
            }
        }
        
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (self.parent as? HomeViewController)?.hideSearchField()
        if (searchText == nil || searchText == "") && indexPath.row == 0 {
            let createPODVC = CreatePodViewController()
            navigationController?.pushViewController(createPODVC, animated: true)
        } else if (searchText == nil || searchText == ""){
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = myPods[indexPath.row - 1]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.pListener = self
            self.podSelected = selectedPOD;
            navigationController?.pushViewController(podDetailsVC, animated: true)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
            podDetailsVC.pListener = self
            self.podSelected = selectedPOD;

            navigationController?.pushViewController(podDetailsVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        let cellSize = CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)

        return cellSize

        /*if (searchText == nil || searchText == "") && indexPath.row == 0 {
            return cellSize
        } else if (searchText == nil || searchText == ""){
            let selectedPOD = allPods[indexPath.row - 1]
            return self.getCellSize(selectedPOD)
        } else {
            let selectedPOD = filteredPODs[indexPath.row]
            return self.getCellSize(selectedPOD)
        } */
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func getCellSize(_ pod: POD) -> CGSize {
        let cellSize = CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)
        
        let image_width = CGFloat(pod.image_width!)
        let image_height = CGFloat(pod.image_height!)
        
        if image_width == 0 || image_height == 0 {
            return cellSize
        } else {
            let real_width = cellSize.width
            let real_height = real_width * image_height / image_width
            
            return CGSize(width: real_width, height: real_height)
        }
    }
    
    // MARK: Search Posts
    
    func filterResults(_ textToSearch: String) {
        print("Search text: \(textToSearch)")
        
        searchText = textToSearch
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredPODs = allPods.filter({( pod : POD) -> Bool in
                return (pod.name!.lowercased().contains(textToSearch.lowercased()))
            })
            allPODstableView.reloadData()
        } else {
            filteredPODs = myPods.filter({( pod : POD) -> Bool in
                return (pod.name!.lowercased().contains(textToSearch.lowercased()))
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
        self.parent?.navigationItem.titleView = segmentedControl
    }
    
    // MARK: - Auxiliary methods
    
    func checkPrivatePODs(_ goToViewController: UIViewController, pod: POD?) {
        if pod != nil {
            var isMember = false
            for user in (pod?.users)! {
                if user.id == networkController.currentUserId {
                    isMember = true
                    break
                }
            }
            
            if pod!.isPrivate == 1 && pod?.owner?.id != networkController.currentUserId && !isMember {
                let alert = UIAlertController(title: "Access", message: "This is a PRIVATE POD, do you want to request access to it?", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Request", style: UIAlertActionStyle.default, handler: { action in
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
                alert.addAction(UIAlertAction(title: "Not now", style: UIAlertActionStyle.cancel, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(goToViewController, animated: true)
            }
            
        }
    }
    
    func loadData(_ pullToRefresh: Bool) {
        page = 0
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        networkController.filterPOD(nil, userId: nil, fromDate: nil, toDate: nil, quantity: kPageQuantity, page: 0, sort_by: nil) { (pods, error) -> () in
            
            if error == nil {
                
                self.allPods = pods
                if self.allPods.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No PODs has been created\n\nwhy don't create a POD?")
                }
                for pod in self.allPods {
                    let result = self.myPods.filter{ $0.id == pod.id}
                    if(result.count != 0)
                    {
                        pod.isMyFeed = true;
                    }
                }

                self.allPODstableView.reloadData()
                
                // load mypods info
                self.loadMyData(pullToRefresh)
                
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
                self.allPODstableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func loadNextPODs() {
        page = page + 1
        networkController.filterPOD(nil, userId: nil, fromDate: nil, toDate: nil, quantity: kPageQuantity, page: page, sort_by: nil) {  (pods, error) -> () in
            if error == nil {
                self.allPods.append(contentsOf: pods)
                for pod in self.allPods {
                    let result = self.myPods.filter{ $0.id == pod.id}
                    if(result.count != 0)
                    {
                        pod.isMyFeed = true;
                    }
                }

                self.allPODstableView.reloadData()
                
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
            self.allPODstableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    func loadMyData(_ pullToRefresh: Bool) {
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        networkController.filterPOD(nil, userId: networkController.currentUserId, fromDate: nil, toDate: nil, quantity: 100, page: 0, sort_by: nil) { (pods, error) -> () in
            
            if error == nil {
                self.isDataLoaded = true
                self.myPods = pods
                for pod in self.allPods {
                    let result = self.myPods.filter{ $0.id == pod.id}
                    if(result.count != 0)
                    {
                        pod.isMyFeed = true;
                    }
                }
                self.allPODstableView.reloadData()

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
                self.allPODstableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func addTableEmptyMessage(_ message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: allPODstableView.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        allPODstableView.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        allPODstableView.backgroundView = nil
    }
    
}
