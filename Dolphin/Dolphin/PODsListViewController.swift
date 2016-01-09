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
        self.parentViewController?.navigationItem.titleView = segmentedControl
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
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchText != nil && searchText != "" {
            return filteredPODs.count
        } else {
            return myPods.count
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
            cell!.configureWithPOD(myPods[indexPath.row])
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width / 2) - 15, height: self.view.frame.size.width / 2.5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //        (cell as? MyPODPreviewCollectionViewCell)?.addUserImages(myPods[indexPath.row])
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
    
}
