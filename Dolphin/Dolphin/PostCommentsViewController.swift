//
//  PostCommentsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/3/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostCommentsViewController : DolphinViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        
        title = "Dolphin"
        setBackButton()
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.separatorStyle = .None
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.postComments!.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
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
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of comment cells
        if indexPath.row % 2 == 0 {
            (cell as? PostCommentEvenTableViewCell)?.adjustCellViews()
        } else {
            (cell as? PostCommentOddTableViewCell)?.adjustCellViews()
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Header for comments
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let headerImage = UIImageView(frame: CGRect(x: self.view.frame.size.width * 3 / 8.0, y: 5, width: self.view.frame.size.width / 4.0, height: 20))
        headerView.backgroundColor = UIColor.clearColor()
        headerImage.backgroundColor = UIColor.clearColor()
        headerImage.contentMode = .ScaleAspectFit
        headerImage.image = UIImage(named: "CommentsTitleImage")
        headerView.addSubview(headerImage)
        return headerView
    }
    
}
