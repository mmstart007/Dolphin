//
//  PostDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class PostDetailsViewController : DolphinViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
 
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setRightSystemButtonItem(.Action, target: self, action: "actionButtonTapped")
        
        title = "Dolphin"
        tableView.registerNib(UINib(nibName: "PostDetailHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailHeaderTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.separatorStyle = .None
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
            return self.view.frame.size.height / 2.7
        } else {
            return 80
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row % 2 == 0 {
                (cell as? PostCommentEvenTableViewCell)?.adjustCellViews()
            } else {
                (cell as? PostCommentOddTableViewCell)?.adjustCellViews()
            }
        }
    }
    
    // MARK: Actions
    
    func actionButtonTapped() {
        print("Action button pressed")
    }
    
}
