//
//  PostDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SDWebImage

class PostDetailsViewController : DolphinViewController, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PostDetailsTopicsAndViewsTableViewCellDelegate {

    let networkController = NetworkController.sharedInstance
    let commentTextViewPlaceHolder: String! = "Write a comment..."
    let picker = UIImagePickerController()
    
    var post: Post?
    var needToReloadPost = false
    var contentOffset: CGFloat = 0
    var actionMenu: UIView? = nil
    var chosenImage: UIImage? = nil
    
    @IBOutlet weak var actionMenuBackground: UIView!
    @IBOutlet weak var writeCommentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var chosenImageContainer: UIView!
    @IBOutlet weak var chosenImageView: UIImageView!
    @IBOutlet weak var firstActionButton: UIButton!
    @IBOutlet weak var secondActionButton: UIButton!
    @IBOutlet weak var thirdActionButton: UIButton!
    @IBOutlet weak var fourthActionButton: UIButton!
    @IBOutlet weak var fifthActionButton: UIButton!
    @IBOutlet weak var sixthActionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    convenience init() {
        self.init(nibName: "PostDetailsViewController", bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAppearance()
        setNavBarButtons()
        
        title = "Dolphin"
        tableView.registerNib(UINib(nibName: "PostDetailHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailHeaderTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.registerNib(UINib(nibName: "PostDetailsTopicsAndViewsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostDetailsTopicsAndViewsTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 10
        
        addKeyboardObservers()
        if needToReloadPost {
            loadPost()
        }
        else {
            loadComments(true)
        }
    }
    
    func setAppearance() {
        self.edgesForExtendedLayout = .None
        title = "Dolphin"
        setBackButton()
        chosenImageContainer.hidden         = true
        commentTextView.layer.cornerRadius  = 10
        commentTextView.layer.masksToBounds = true
        commentTextView.layer.borderWidth   = 1
        commentTextView.layer.borderColor   = UIColor.lightGrayColor().CGColor
        commentTextView.backgroundColor     = UIColor.lightTextColor()
        commentTextView.delegate            = self
        commentTextView.text                = commentTextViewPlaceHolder
        commentTextView.textColor           = UIColor.darkGrayColor()
        let viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        viewTapRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(viewTapRecognizer)
    }
    
    func viewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func setNavBarButtons() {

        // comments new windows
        if(self.post?.postUser?.id == networkController.currentUserId) {
            let customViewRemoveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewRemoveButton.setImage(UIImage(named: "garbage"), forState: .Normal)
            customViewRemoveButton.setImage(UIImage(named: "garbage"), forState: .Highlighted)
            customViewRemoveButton.addTarget(self, action: #selector(removeButtonPressed), forControlEvents: .TouchUpInside)
            let removeBarButton        = UIBarButtonItem(customView: customViewRemoveButton)
            
            let customViewActionButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Normal)
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Highlighted)
            customViewActionButton.addTarget(self, action: #selector(actionButtonPressed), forControlEvents: .TouchUpInside)
            let actionBarButton         = UIBarButtonItem(customView: customViewActionButton)
            
            navigationItem.rightBarButtonItems = [actionBarButton, removeBarButton]
        }

        else {
            let customViewActionButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Normal)
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), forState: .Highlighted)
            customViewActionButton.addTarget(self, action: #selector(actionButtonPressed), forControlEvents: .TouchUpInside)
            let actionBarButton         = UIBarButtonItem(customView: customViewActionButton)
            
            navigationItem.rightBarButtonItems = [actionBarButton]
        }
//        let customViewLikeButton    = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        customViewLikeButton.setImage(UIImage(named: "LikeNavBarIcon"), forState: .Normal)
//        customViewLikeButton.setImage(UIImage(named: "LikeNavBarIcon"), forState: .Highlighted)
//        customViewLikeButton.addTarget(self, action: #selector(likeButtonPressed), forControlEvents: .TouchUpInside)
//        let likeBarButton           = UIBarButtonItem(customView: customViewLikeButton)

        //navigationItem.rightBarButtonItems = [actionBarButton, commentBarButton, likeBarButton]
        
    }
    
    // MARK: NavBar Actions and Action Menu
    func removeButtonPressed() {
        let alertController = UIAlertController(title: nil, message: Constants.Messages.RemovePostMsg, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { action -> Void in
            SVProgressHUD.show()
            let postIdString = String(self.post!.postId!)
            self.networkController.deletePost(postIdString) { (error) -> () in
                SVProgressHUD.dismiss()
                if error == nil {
                    print("post deleted")
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.DeletedPost, object: nil, userInfo: ["post":self.post!])
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        })
        let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func actionButtonPressed() {
        if post?.postType?.name == "link" {
            let imageURL = NSURL(string: (post?.postLink?.imageURL)!)
            
            let shareText = (post?.postText)! + "\n" + Constants.Messages.ShareSuffix + "\n" + Constants.iTunesURL
            let manager = SDWebImageManager.sharedManager()
            
            manager.downloadImageWithURL(imageURL, options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText, image], applicationActivities: nil)
                    self.showActivityController(shareVC)
                } else {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    self.showActivityController(shareVC)
                }
            })

        } else if post?.postType?.name == "text" {
            let shareText = (post?.postHeader)! + "\n" + (post?.postText)! + "\n" + Constants.Messages.ShareSuffix + "\n" + Constants.iTunesURL
            let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            self.showActivityController(shareVC)
        } else {
            
            let imageURL = NSURL(string: (post?.postImage?.imageURL)!)
            let manager = SDWebImageManager.sharedManager()
            let shareText = (post?.postHeader)! + "\n" + (post?.postText)! + "\n" + Constants.Messages.ShareSuffix + "\n" + Constants.iTunesURL
            
            manager.downloadImageWithURL(imageURL, options: .RefreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText, image], applicationActivities: nil)
                    self.showActivityController(shareVC)
                } else {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    self.showActivityController(shareVC)
                }
            })
        }
    }
    
    func showActivityController(shareVC: UIActivityViewController) {
        shareVC.completionWithItemsHandler = {(activityType, success:Bool, items:[AnyObject]?, error:NSError?) in
            if !success {
                print("cancelled")
            }
            else {
                var shareType = Constants.ShareType.Share_Other
                if activityType == UIActivityTypeMail {
                    shareType = Constants.ShareType.Share_Mail
                }
                else if activityType == UIActivityTypeMessage {
                    shareType = Constants.ShareType.Share_SMS
                }
                else if activityType == UIActivityTypePostToFacebook {
                    shareType = Constants.ShareType.Share_Facebook
                }
                else if activityType == UIActivityTypePostToTwitter {
                    shareType = Constants.ShareType.Share_Twitter
                }
                
                self.networkController.createPostShare("\(self.post!.postId!)", type:shareType, completionHandler: { (error) -> () in
                    if error == nil {
                        
                    } else {
                    }
                })
                
            }
        }
        self.presentViewController(shareVC, animated: true, completion: nil)
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

            secondActionButton.layer.cornerRadius = 5
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
        if !(post?.isLikedByUser)! {
            SVProgressHUD.showWithStatus("Loading")
            networkController.createLike("\(post!.postId!)", completionHandler: { (like, error) -> () in
                if error == nil {
                    if like?.id != nil {
                        self.post?.isLikedByUser = true
                        self.post?.postNumberOfLikes = (self.post?.postNumberOfLikes)! + 1
                        self.tableView.reloadData()
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            
            SVProgressHUD.showWithStatus("Loading")
            networkController.deleteLike("\(post!.postId!)", completionHandler: { (error) -> () in
                if error == nil {
                    self.post?.postNumberOfLikes = (self.post?.postNumberOfLikes)! - 1
                    self.post?.isLikedByUser = false
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        }
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
            cell?.contentView.userInteractionEnabled = false
            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.configureWithPost(post!)
            (cell as? PostDetailsTopicsAndViewsTableViewCell)?.delegate = self
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
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of image
        if indexPath.section == 0 {
            (cell as? PostDetailHeaderTableViewCell)?.adjustCellViews()
        }
        // Adjust views of comment cells
        if indexPath.section == 2 {
            if indexPath.row % 2 == 0 {
                (cell as? PostCommentEvenTableViewCell)?.adjustCellViews()
            } else {
                (cell as? PostCommentOddTableViewCell)?.adjustCellViews()
            }
        } else if indexPath.section == 1 {
//            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.collectionView.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
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
    
    // MARK: Keyboard management
    
    func addKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillAppear(sender: NSNotification) {
        print("Keyboard appeared")
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                writeCommentBottomConstraint.constant = keyboardSize.height
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        print("Keyboard hidden")
        writeCommentBottomConstraint.constant = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
    // MARK UItextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == commentTextViewPlaceHolder {
            textView.text = ""
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = commentTextViewPlaceHolder
        }
        textView.resignFirstResponder()
    }
    
    // Photo actions
    
    @IBAction func selectImageButtonTouchUpInside(sender: AnyObject) {
        
        picker.delegate = self
        let alert = UIAlertController(title: "Lets get a picture", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.picker.navigationBar.translucent = false
            self.picker.navigationBar.barTintColor = UIColor.blueDolphin()
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Take Photo")
                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.picker, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func removeImageFromCommentButtonTouchUpInside(sender: AnyObject) {
        chosenImage = nil
        chosenImageView.image = nil
        chosenImageContainer.hidden = true
    }
    
    //MARK: Images Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        chosenImageContainer.hidden = false
        chosenImageView.image = chosenImage!
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Auxiliary methods
    
    func loadPost() {
        SVProgressHUD.showWithStatus("Loading")
        networkController.getPostById(String(post!.postId!), completionHandler: { (post, error) in
            if error == nil {
                self.post = post
                self.loadComments(false)
            }
            else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    func loadComments(showIndicator:Bool) {
        if showIndicator {
            SVProgressHUD.showWithStatus("Loading")
        }
        
        networkController.getPostComments(String(post!.postId!)) { (postComments, error) -> () in
            if error == nil {
                self.post?.postComments = postComments
                self.tableView.reloadData()
                
                //Add Open History.
                self.networkController.createPostOpen(String(self.post!.postId!), completionHandler: { (error) in
                    print(error);
                })
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func postMessageTouchUpInside(sender: AnyObject) {
        print("send message pressed")
        commentTextView.resignFirstResponder()
        if commentTextView.text != "" && commentTextView.text != "Write a comment..." {
            SVProgressHUD.showWithStatus("Sending comment")
            let commentToSend = PostComment(text: commentTextView.text, image: nil)
            networkController.createComment("\(post!.postId!)", postComment: commentToSend, completionHandler: { (comment, error) -> () in
                if error == nil {
                    if comment?.postCommentId != nil {
                        // add the comment returned locally
                        self.post?.postComments?.append(comment!)
                        // everything worked ok, reload the table of comments
                        self.tableView.reloadData()
                        // reset the field
                        self.commentTextView.text = ""
                        // after a delay, scroll the table to the last comment
                        let delay = 0.1 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue(), {
                            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.post!.postComments!.count - 1, inSection: 2), atScrollPosition: .Bottom, animated: true)
                        })
                    } else {
                        print("there was an error saving the post")
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
            
        } else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "The message can't be empty!", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Topic
    func tapTopic(topic: Topic?) {
        let topicPost = TagPostsViewController(likes: false)
        topicPost.selectedTopic = topic
        navigationController?.pushViewController(topicPost, animated: true)
    }
}
