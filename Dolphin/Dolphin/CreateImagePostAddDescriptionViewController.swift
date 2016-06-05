//
//  CreateImagePostAddDescriptionViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
import KSTokenView

class CreateImagePostAddDescriptionViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, KSTokenViewDelegate {

    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var tableViewPostDetails: UITableView!
    
    var postImage: UIImage?
    // if this var is set, I'm creating a text post from a POD
    var podId: Int?
    let tags: Array<String> = List.names()
    
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

   
    // MARK: - Actions
    func postButtonTouchUpInside() {

        let cellInfo = tableViewPostDetails.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? CreatePostAddDescriptionTableViewCell
        
        //Hide Keyboard
        cellInfo?.textViewDescription.resignFirstResponder()
        cellInfo?.textFieldPostTitle.resignFirstResponder()
        cellInfo?.postTagsTextView.resignFirstResponder()

        //Get Info.
        let title = cellInfo?.textFieldPostTitle.text
        let description = cellInfo?.textViewDescription.text
        let topicsStringArray = cellInfo?.postTagsTextView.tokens()
        var topics: [Topic] = []
        if topicsStringArray != nil {
            for t in topicsStringArray! {
                topics.append(Topic(name: t.title))
            }
        }

        if title != "" && description != "" {
            
            SVProgressHUD.showWithStatus("Posting")
            dispatch_async(dispatch_get_main_queue()) {
                // do your stuff here
                // crate the image pod
                let post = Post(user: nil, image: nil, imageData: self.postImage, imageWidth: Float(self.postImage!.size.width), imageHeight: Float(self.postImage!.size.height), type: PostType(name: "image"), topics: topics, link: nil, imageUrl: nil, title: title, text: description, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil, PODId: self.podId)
                self.networkController.createPost(post, completionHandler: { (post, error) -> () in
                    if error == nil {
                        
                        if post?.postId != nil {
                            // everything worked ok
                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPost, object: nil, userInfo: ["post":post!])
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
            }
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
        var cell: CreatePostAddDescriptionTableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("CreatePostAddDescriptionTableViewCell") as? CreatePostAddDescriptionTableViewCell
            if cell == nil {
                cell = CreatePostAddDescriptionTableViewCell()
            }
            cell?.textFieldPostTitle.delegate = self
            cell?.textViewDescription.delegate = self
            cell?.postTagsTextView.delegate    = self

            cell?.configureWithImage(false, postImage: postImage, postURL: nil, postImageURL: nil)
        }
        cell?.contentView.userInteractionEnabled = false
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (self.view.frame.height - (self.navigationController?.navigationBar.frame.size.height)! + 50.0)
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewPostDetails.registerNib(UINib(nibName: "CreatePostAddDescriptionTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CreatePostAddDescriptionTableViewCell")
        
    }
    
    // MARK: UITextField Delegate.
    func textFieldDidBeginEditing(textField: UITextField) {
        tableViewPostDetails.setContentOffset(CGPointMake(0.0, 200.0), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tableViewPostDetails.setContentOffset(CGPointZero, animated: true)
    }
    
    // MARK: UITextView Delegate.
    func textViewDidBeginEditing(textView: UITextView) {
        tableViewPostDetails.setContentOffset(CGPointMake(0.0, 200.0), animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        tableViewPostDetails.setContentOffset(CGPointZero, animated: true)
    }
    
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var data: Array<String> = []
        for value: String in tags {
            if value.lowercaseString.rangeOfString(string.lowercaseString) != nil {
                data.append(value)
            }
        }
        completion!(results: data)
    }
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
    
    func tokenViewDidBeginEditing(tokenView: KSTokenView) {
        tableViewPostDetails.setContentOffset(CGPointMake(0.0, 400.0), animated: true)
    }
    
    func tokenViewDidEndEditing(tokenView: KSTokenView) {
        tableViewPostDetails.setContentOffset(CGPointZero, animated: true)
    }
}
