//
//  PostDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostDetailsViewController : DolphinViewController, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post?
    var topics: [String] = []
    var contentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setRightSystemButtonItem(.Action, target: self, action: "actionButtonTapped")
        title = "Dolphin"
        tableView.registerNib(UINib(nibName: "PostDetailHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailHeaderTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.registerNib(UINib(nibName: "PopularTrendingTopicsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PopularTrendingTopicsTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 10
        
        // Test data
        topics = ["ECONOMICS", "POLITICS", "COMPUTER SCIENCE", "SYRIA", "K-12"]
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return (post?.postComments!.count)!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("PostDetailHeaderTableViewCell") as? PostDetailHeaderTableViewCell
            if cell == nil {
                cell = PostDetailHeaderTableViewCell()
            }
            (cell as? PostDetailHeaderTableViewCell)?.configureWithPost(post!)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("PopularTrendingTopicsTableViewCell") as? PopularTrendingTopicsTableViewCell
            if cell == nil {
                cell = PopularTrendingTopicsTableViewCell()
            }
            (cell as? PopularTrendingTopicsTableViewCell)!.configureWithDataSource(self, delegate: self, centerAligned: false)
        } else {
            if indexPath.row % 2 == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentEvenTableViewCell") as? PostCommentEvenTableViewCell
                if cell == nil {
                    cell = PostCommentEvenTableViewCell()
                }
                (cell as? PostCommentEvenTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentOddTableViewCell") as? PostCommentOddTableViewCell
                if cell == nil {
                    cell = PostCommentOddTableViewCell()
                }
                (cell as? PostCommentOddTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
            }
            
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.frame.size.height / 3
        } else if indexPath.section == 1 {
            return 40
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of comment cells
        if indexPath.section == 2 {
            if indexPath.row % 2 == 0 {
                (cell as? PostCommentEvenTableViewCell)?.adjustCellViews()
            } else {
                (cell as? PostCommentOddTableViewCell)?.adjustCellViews()
            }
        } else if indexPath.section == 1 {
            (cell as? PopularTrendingTopicsTableViewCell)!.collectionView.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Only header for comments section
        if section == 2 {
            return 30
        } else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Only header for comments section
        if section == 2 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
            let headerImage = UIImageView(frame: CGRect(x: self.view.frame.size.width * 3 / 8.0, y: 5, width: self.view.frame.size.width / 4.0, height: 20))
            headerView.backgroundColor = UIColor.clearColor()
            headerImage.backgroundColor = UIColor.clearColor()
            headerImage.contentMode = .ScaleAspectFit
            headerImage.image = UIImage(named: "CommentsTitleImage")
            headerView.addSubview(headerImage)
            return headerView
        } else {
            return UIView()
        }
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let postCommentsVC  = PostCommentsViewController(post: post!)
            navigationController?.pushViewController(postCommentsVC, animated: true)
        }
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: TopicCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("TopicCollectionViewCell", forIndexPath: indexPath) as? TopicCollectionViewCell
        if cell == nil {
            cell = TopicCollectionViewCell()
        }
        cell?.configureWithName(topics[indexPath.row].uppercaseString, color: UIColor.topicsColorsArray()[indexPath.row % UIColor.topicsColorsArray().count])
        collectionView.userInteractionEnabled = true
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let text = topics[indexPath.row].uppercaseString
        let font = UIFont.systemFontOfSize(16)
        let textString = text as NSString
        
        let textAttributes = [NSFontAttributeName: font]
        var size = textString.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 20, 35), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil).size
        if size.width < self.view.frame.size.width / 4 {
            size = CGSize(width: self.view.frame.size.width / 4, height: size.height)
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView.classForCoder()) {
            return
        } else {
            self.contentOffset = scrollView.contentOffset.x
            
        }
    }

    
    // MARK: Actions
    
    func actionButtonTapped() {
        print("Action button pressed")
    }
    
}
