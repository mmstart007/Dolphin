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
    var actionMenu: UIView? = nil
    @IBOutlet weak var actionMenuBackground: UIView!

    @IBOutlet weak var firstActionButton: UIButton!
    @IBOutlet weak var secondActionButton: UIButton!
    @IBOutlet weak var thirdActionButton: UIButton!
    @IBOutlet weak var fourthActionButton: UIButton!
    @IBOutlet weak var fifthActionButton: UIButton!
    @IBOutlet weak var sixthActionButton: UIButton!
    
    convenience init() {
        self.init(nibName: "PostDetailsViewController", bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        
        setNavBarButtons()
        
        title = "Dolphin"
        tableView.registerNib(UINib(nibName: "PostDetailHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailHeaderTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.registerNib(UINib(nibName: "PostDetailsTopicsAndViewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailsTopicsAndViewsTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 10
        
        // Test data
        topics = ["ECONOMICS", "POLITICS", "COMPUTER SCIENCE", "SYRIA", "K-12"]
    }
    
    func setNavBarButtons() {
        
        let customViewActionButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Normal)
        customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Highlighted)
        customViewActionButton.addTarget(self, action: "actionButtonPressed", forControlEvents: .TouchUpInside)
        let actionBarButton         = UIBarButtonItem(customView: customViewActionButton)

        let customViewCommentButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        customViewCommentButton.setImage(UIImage(named: "CommentsNavBarIcon"), forState: .Normal)
        customViewCommentButton.setImage(UIImage(named: "CommentsNavBarIcon"), forState: .Highlighted)
        customViewCommentButton.addTarget(self, action: "commentButtonPressed", forControlEvents: .TouchUpInside)
        let commentBarButton        = UIBarButtonItem(customView: customViewCommentButton)

        let customViewLikeButton    = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        customViewLikeButton.setImage(UIImage(named: "LikeNavBarIcon"), forState: .Normal)
        customViewLikeButton.setImage(UIImage(named: "LikeNavBarIcon"), forState: .Highlighted)
        customViewLikeButton.addTarget(self, action: "likeButtonPressed", forControlEvents: .TouchUpInside)
        let likeBarButton           = UIBarButtonItem(customView: customViewLikeButton)

        navigationItem.rightBarButtonItems = [actionBarButton, commentBarButton, likeBarButton]
        
    }
    
    // MARK: NavBar Actions and Action Menu
    
    func actionButtonPressed() {
        print("Action Button Pressed")
        let subViewsArray = NSBundle.mainBundle().loadNibNamed("PostDetailsActionView", owner: self, options: nil)
        
        self.actionMenu = subViewsArray[0] as? UIView
        setupActionMenuFields()
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
    
    func setupActionMenuFields() {
        if self.actionMenu != nil {
            firstActionButton.layer.cornerRadius  = 5
            firstActionButton.layer.borderWidth   = 1
            firstActionButton.layer.borderColor   = UIColor.darkGrayColor().CGColor

            fourthActionButton.layer.cornerRadius = 5
            fourthActionButton.layer.borderWidth  = 1
            fourthActionButton.layer.borderColor  = UIColor.darkGrayColor().CGColor

            sixthActionButton.layer.cornerRadius  = 5
            sixthActionButton.layer.borderWidth   = 1
            sixthActionButton.layer.borderColor   = UIColor.darkGrayColor().CGColor
            
            secondActionButton.layer.cornerRadius  = 5
            thirdActionButton.layer.cornerRadius  = 5
            fifthActionButton.layer.cornerRadius  = 5
        }
    }
    
    @IBAction func closePostActionViewTouchUpInside(sender: AnyObject) {
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
    
    func actionMenuBackgroundTapped() {
        closePostActionViewTouchUpInside(self)
    }
    
    func commentButtonPressed() {
        print("Comment Button Pressed")
        let postCommentsVC  = PostCommentsViewController(post: post!)
        navigationController?.pushViewController(postCommentsVC, animated: true)
    }
    
    func likeButtonPressed() {
        if (post?.isLikedByUser)! {
            post?.isLikedByUser = false
            post?.postNumberOfLikes = (post?.postNumberOfLikes)! - 1
        } else {
            post?.isLikedByUser = true
            post?.postNumberOfLikes = (post?.postNumberOfLikes)! + 1
        }
        tableView.reloadData()
        print("Like Button Pressed")
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
            cell = tableView.dequeueReusableCellWithIdentifier("PostDetailsTopicsAndViewsTableViewCell") as? PostDetailsTopicsAndViewsTableViewCell
            if cell == nil {
                cell = PostDetailsTopicsAndViewsTableViewCell()
            }
            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.configureWithPost(post!, dataSource: self, delegate: self)
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
            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.collectionView.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
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
    
}
