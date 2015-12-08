//
//  FeedViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var postsTableView: UITableView!
    
    var posts: [Post] = []
    var cells: [PostTableViewCell] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        postsTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostTableViewCell")
        postsTableView.separatorStyle = .None
        postsTableView.estimatedRowHeight = 1000
        
        // Populate data for testing layout purposes
        let user1 = User(name: "John Doe", imageURL: "")
        
        let comment1 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
        let comment2 = PostComment(user: user1, text: "I'll say!", date: NSDate())
        let comment3 = PostComment(user: user1, text: "This is a larger comment than the previos one, I just want to test the cell height!", date: NSDate())
        let comment4 = PostComment(user: user1, text: "This comment is even larger than the other one, and it is loooooooooooooooooooooooooooooooooooooooooooooooooooooong", date: NSDate())
        let comment5 = PostComment(user: user1, text: "Great, the layout on the comments looks awesome!", date: NSDate())
        
        let post1 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: .URL, header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfViews: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5])
        let post2 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfViews: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5])
        let post3 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfViews: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5])
        posts = [post1, post2, post3]
    }
 
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PostTableViewCell? = postsTableView.dequeueReusableCellWithIdentifier("PostTableViewCell") as? PostTableViewCell
        if cell == nil {
            cell = PostTableViewCell()
        }
        cell?.configureWithPost(posts[indexPath.row])
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as? PostTableViewCell {
            postCell.adjustCellViews(posts[indexPath.row])
        }
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let postDetailsVC = PostDetailsViewController()
        postDetailsVC.post = posts[indexPath.row]
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
    
}
