//
//  PopularViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/2/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PopularViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    
    var topics: [String] = []
    var pods: [POD]      = []
    var posts: [Post]    = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (parentViewController as? HomeViewController)?.removeRightButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        
        tableView.registerNib(UINib(nibName: "PopularTrendingTopicsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PopularTrendingTopicsTableViewCell")
        tableView.registerNib(UINib(nibName: "PopularPODsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PopularPODsTableViewCell")
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 400
        
        // Populate data for testing layout purposes
        let user1 = User(deviceId: "", userName: "John Doe", imageURL: "", email: "john@doe.com", password: "test")
        
//        let comment1 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
//        let comment2 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
//        let comment3 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
//        let comment4 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
//        let comment5 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
        
//        let post1 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: "url", header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfLikes: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        let post2 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: false)
//        let post3 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        posts = [post1, post2, post3]
//        
//        let pod1 = POD(name: "Aviation", imageURL: "https://wallpaperscraft.com/image/plane_sky_flying_sunset_64663_3840x1200.jpg", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1, user1], isPrivate: true)
//        let pod2 = POD(name: "Engineering", imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRcMgu3PJLY079zBrxFxZRDwl59nuVuluNdF6PtqJvIzoD39YCQKg", lastpostDate: NSDate(), users: [user1, user1, user1], isPrivate: false)
//        let pod3 = POD(name: "Electronics", imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUTqYPZGV5hcCSTuoRf_VR1lbN6lFZvGn8ufGPBNCEVRj7gdN3TA", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1], isPrivate: true)
//        
//        pods = [pod1, pod2, pod3]
        
        topics = ["ECONOMICS", "POLITICS", "COMPUTER SCIENCE", "SYRIA", "K-12"]
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1{
            return 1
        } else {
            return posts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("PopularTrendingTopicsTableViewCell") as? PopularTrendingTopicsTableViewCell
            if cell == nil {
                cell = PopularTrendingTopicsTableViewCell()
            }
            (cell as? PopularTrendingTopicsTableViewCell)!.configureWithDataSource(self, delegate: self, centerAligned: true)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("PopularPODsTableViewCell") as? PopularPODsTableViewCell
            if cell == nil {
                cell = PopularPODsTableViewCell()
            }
            (cell as? PopularPODsTableViewCell)!.configureWithDataSource(self, delegate: self)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
            if cell == nil {
                cell = PostTableViewCell()
            }
            (cell as? PostTableViewCell)!.configureWithPost(posts[indexPath.row])
        }
        
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            return self.view.frame.size.width / 3
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor.clearColor()
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.textAlignment = .Center
        headerLabel.font = UIFont.boldSystemFontOfSize(11)
        headerLabel.textColor = UIColor.darkGrayColor()
        if section == 0 {
            headerLabel.text = "TRENDING TOPICS"
        } else if section == 1 {
            headerLabel.text = "POPULAR PODS"
        } else if section == 2 {
            headerLabel.text = "POPULAR POSTS"
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of comment cells
        if indexPath.section == 1 {
            cell.selectionStyle = .None
        }
    }
    
    // MARK: - Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = posts[indexPath.row]
            navigationController?.pushViewController(postDetailsVC, animated: true)
        }
    }
    
    // MARK: - CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return topics.count
        } else if collectionView.tag == 1 {
            return pods.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("TopicCollectionViewCell", forIndexPath: indexPath) as? TopicCollectionViewCell
            if cell == nil {
                cell = TopicCollectionViewCell()
            }
            cell?.configureWithName(topics[indexPath.row].uppercaseString, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
            return cell!
        } else {
            var cell: PODCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("PODCollectionViewCell", forIndexPath: indexPath) as? PODCollectionViewCell
            if cell == nil {
                cell = PODCollectionViewCell()
            }
            cell?.configureWithPOD(pods[indexPath.row])
            return cell!
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let text = topics[indexPath.row].uppercaseString
            let font = UIFont.systemFontOfSize(16)
            let textString = text as NSString
            
            let textAttributes = [NSFontAttributeName: font]
            var size = textString.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 20, 35), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil).size
            if size.width < self.view.frame.size.width / 4 {
                size = CGSize(width: self.view.frame.size.width / 4, height: size.height)
            }
            return size
        } else {
            return CGSize(width: self.view.frame.size.width / 3.8, height: self.view.frame.size.width / 3.8)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    // MARK: - CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.tag == 0 {
            print("Topic %@ pressed", topics[indexPath.row])
        } else if collectionView.tag == 1 {
            print("Pod %@ pressed", pods[indexPath.row].podName)
            let podDetailsVC = PODDetailsViewController()
            let selectedPOD = pods[indexPath.row]
            podDetailsVC.pod = selectedPOD
            navigationController?.pushViewController(podDetailsVC, animated: true)
            
        }

    }

}
