//
//  PODsListViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PODsListViewController : UIViewController, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var allPODstableView: UITableView!
    @IBOutlet weak var myPODsCollectionView: UICollectionView!
    var segmentedControl: UISegmentedControl!
    
    var allPods: [POD]      = []
    var myPods: [POD]       = []
    var filteredPODs: [POD] = []
    var searchText: String? = nil
    
    required init() {
        super.init(nibName: "PODsListViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        allPODstableView.registerNib(UINib(nibName: "PODPreviewTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PODPreviewTableViewCell")
        myPODsCollectionView.registerNib(UINib(nibName: "MyPODPreviewCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "MyPODPreviewCollectionViewCell")
        myPODsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        allPODstableView.separatorStyle = .None
        myPODsCollectionView.dataSource = self
        myPODsCollectionView.delegate   = self
        
        let user1 = User(name: "John Doe", imageURL: "")
        
        let pod1 = POD(name: "Aviation", imageURL: "https://wallpaperscraft.com/image/plane_sky_flying_sunset_64663_3840x1200.jpg", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1, user1], isPrivate: true)
        let pod2 = POD(name: "Engineering", imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRcMgu3PJLY079zBrxFxZRDwl59nuVuluNdF6PtqJvIzoD39YCQKg", lastpostDate: NSDate(), users: [user1, user1, user1], isPrivate: false)
        let pod3 = POD(name: "Electronics", imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUTqYPZGV5hcCSTuoRf_VR1lbN6lFZvGn8ufGPBNCEVRj7gdN3TA", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1], isPrivate: true)
        
        allPods = [pod1, pod2, pod3]
        myPods = [pod1, pod2, pod3]
        
        segmentedControl = UISegmentedControl(items: ["All PODs", "My PODs"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        
        
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
        return 230
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if searchText != nil && searchText != "" {
            (cell as? PODPreviewTableViewCell)!.addUserImages(filteredPODs[indexPath.row])
        } else {
            (cell as? PODPreviewTableViewCell)!.addUserImages(allPods[indexPath.row])
        }
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("POD selected: " + String(indexPath.row))
        
        if (searchText == nil || searchText == "") {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = allPods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
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
        
        if (searchText == nil || searchText == "") && indexPath.row == 0 {
            let createPODVC = CreatePodViewController()
            checkPrivatePODs(createPODVC, pod: nil)
        } else if (searchText == nil || searchText == ""){
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = allPods[indexPath.row - 1]
            podDetailsVC.pod = selectedPOD
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        } else {
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = filteredPODs[indexPath.row]
            podDetailsVC.pod = selectedPOD
            checkPrivatePODs(podDetailsVC, pod: selectedPOD)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)
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
                return (pod.podName!.lowercaseString.containsString(textToSearch.lowercaseString))
            })
            allPODstableView.reloadData()
        } else {
            filteredPODs = myPods.filter({( pod : POD) -> Bool in
                return (pod.podName!.lowercaseString.containsString(textToSearch.lowercaseString))
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
        if pod != nil && pod!.podIsPrivate {
            let alert = UIAlertController(title: "Access", message: "This is a PRIVATE POD, do you want to request access to it?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Request", style: UIAlertActionStyle.Default, handler: { action in
                self.navigationController?.pushViewController(goToViewController, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Not now", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(goToViewController, animated: true)
        }
    }
    
}
