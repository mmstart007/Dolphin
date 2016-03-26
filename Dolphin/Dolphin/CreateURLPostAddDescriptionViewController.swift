//
//  CreateURLPostAddDescriptionViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateURLPostAddDescriptionViewController: DolphinViewController, UITableViewDataSource, UITableViewDelegate {

    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var tableViewPostDetails: UITableView!
    
    var postImageURL: String?
    var postURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        setRightButtonItemWithText("Post", target: self, action: "postButtonTouchUpInside")
        self.edgesForExtendedLayout     = .None
        title                           = "Add description"
        tableViewPostDetails.delegate   = self
        tableViewPostDetails.dataSource = self
        tableViewPostDetails.tableFooterView = UIView(frame: CGRectZero)
        registerCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func postButtonTouchUpInside() {
        print("postButtonTouchUpInside")
        
        let cellInfo = tableViewPostDetails.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? CreatePostAddDescriptionTableViewCell
        let description = cellInfo?.textViewDescription.text
        
        if description != "" {
            let link = Link(url: postURL!, imageURL: postImageURL!)
            // crate the pod
            let post = Post(user: nil, image: nil, imageData: nil, type: PostType(name: "link"), topics: nil, link: link, imageUrl: nil, title: nil, text: description, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil)
            SVProgressHUD.showWithStatus("Posting")
            networkController.createPost(post, completionHandler: { (post, error) -> () in
                if error == nil {
                    
                    if post?.postId != nil {
                        // everything worked ok
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        // there was an error saving the post
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    var alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        } else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "Please, fill all the fields", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("CreatePostAddDescriptionTableViewCell") as? CreatePostAddDescriptionTableViewCell
            if cell == nil {
                cell = CreatePostAddDescriptionTableViewCell()
            }
            (cell as? CreatePostAddDescriptionTableViewCell)?.configureWithImage(true, postImage: nil, postURL: postURL, postImageURL: postImageURL)
        }
        cell?.contentView.userInteractionEnabled = false
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 375
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewPostDetails.registerNib(UINib(nibName: "CreatePostAddDescriptionTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CreatePostAddDescriptionTableViewCell")
        
    }
    

    
}
