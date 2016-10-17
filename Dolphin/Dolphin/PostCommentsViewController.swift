//
//  PostCommentsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/3/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class PostCommentsViewController : DolphinViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,ChooseSourceTypeViewDelegate {
    
    @IBOutlet weak var ViewTypeCancel: UIButton!
    @IBOutlet weak var ViewTypeParent: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var writeCommentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var chosenImageContainer: UIView!
    @IBOutlet weak var chosenImageView: UIImageView!

    let picker = UIImagePickerController()
    let networkController = NetworkController.sharedInstance
    let commentTextViewPlaceHolder: String! = "Write a comment..."
    
    var post: Post?
    var chosenImage: UIImage? = nil
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    
    init(post: Post) {
        super.init(nibName: "PostCommentsViewController", bundle: nil)
        self.post = post
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.loadComments(true)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        tableView.registerNib(UINib(nibName: "PostCommentOddTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentEvenTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentImageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentImageTableViewCell")
        tableView.registerNib(UINib(nibName: "PostCommentImageLeftTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PostCommentImageLeftTableViewCell")
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 10
        self.ViewTypeParent.hidden = true
        addKeyboardObservers()
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
        let viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTapRecognizer)
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.postComments!.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
        if indexPath.row % 2 == 1 {
            if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
            {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentImageTableViewCell") as? PostCommentImageTableViewCell
                if cell == nil {
                    cell = PostCommentImageTableViewCell()
                }
                (cell as? PostCommentImageTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                (cell as? PostCommentImageTableViewCell)?.controller = self
                (cell as? PostCommentImageTableViewCell)?.mPost = self.post
                
            }
            else{
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentEvenTableViewCell") as? PostCommentEvenTableViewCell
                if cell == nil {
                    cell = PostCommentEvenTableViewCell()
                }
                (cell as? PostCommentEvenTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                (cell as? PostCommentEvenTableViewCell)?.controller = self
                (cell as? PostCommentEvenTableViewCell)?.mPost = self.post
            }
            
        } else {
            if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
            {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentImageLeftTableViewCell") as? PostCommentImageLeftTableViewCell
                if cell == nil {
                    cell = PostCommentImageLeftTableViewCell()
                }
                (cell as? PostCommentImageLeftTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                (cell as? PostCommentImageLeftTableViewCell)?.controller = self
                (cell as? PostCommentImageLeftTableViewCell)?.mPost = self.post
            }
            else{
                cell = tableView.dequeueReusableCellWithIdentifier("PostCommentOddTableViewCell") as? PostCommentOddTableViewCell
                if cell == nil {
                    cell = PostCommentOddTableViewCell()
                }
                
                (cell as? PostCommentOddTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                (cell as? PostCommentOddTableViewCell)?.controller = self
                (cell as? PostCommentOddTableViewCell)?.mPost = self.post
            }
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.post!.postComments?.count > 0)
        {
            let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
            if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
            {
                
                let screenWidth = screenSize.width - 10
                var radio : CGFloat? = CGFloat(screenWidth/(commentInfo?.postLink != nil ? commentInfo?.postLink?.imageWidth : commentInfo?.postImage?.imageWidth)!)
                var height:CGFloat? = CGFloat((commentInfo?.postLink != nil ? commentInfo?.postLink?.imageHeight : commentInfo?.postImage?.imageHeight!)!*radio!)
                
                if(!(height?.isNaN)!)
                {
                    return height!
                }
                return 350
            }
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Adjust views of comment cells
        let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
        
        if indexPath.row % 2 == 0 {
            if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
            {
            (cell as? PostCommentImageTableViewCell)?.adjustCellViews()
            }
            else{
                (cell as? PostCommentEvenTableViewCell)?.adjustCellViews()
            }
        } else {
            if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
            {
            (cell as? PostCommentImageLeftTableViewCell)?.adjustCellViews()
            }
            else{
                (cell as? PostCommentOddTableViewCell)?.adjustCellViews()
            }
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
    
    // MARK: - Keyboard management
    
    func addKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillAppear:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
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
    
    func viewTapped() {
        commentTextView.resignFirstResponder()
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
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.ViewTypeParent?.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.ViewTypeParent.hidden = false
                self.ViewTypeCancel.alpha = 0.4
            })
        }
        /*let alert = UIAlertController(title: "Lets get a picture", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
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
        self.presentViewController(alert, animated: true, completion: nil)*/
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
        let screenWidth = (screenSize.width - 10)*2
        var radio : CGFloat? = CGFloat(screenWidth/(self.chosenImage?.size.width)!)
        
        let intWidth :CGFloat? = CGFloat(screenWidth)
        let intHeight :CGFloat? = CGFloat((self.chosenImage?.size.height)!*radio!)
        
        chosenImage = self.ResizeImage(chosenImage!, targetSize: CGSizeMake(intWidth!, intHeight!))
        chosenImageContainer.hidden = false

        chosenImageContainer.hidden = false
        chosenImageView.image = chosenImage!
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectedCamera() {
        self.closedDialog()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            Utils.presentAlertMessage("Error", message: "Device has no camera", cancelActionText: "Ok", presentingViewContoller: self)
        }
    }
    
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
    }
    
    func selectedPhotoGallery() {
        self.closedDialog()
        
        self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.picker.delegate   = self
        self.picker.allowsEditing = true
        self.picker.navigationBar.tintColor = UIColor.whiteColor()
        self.picker.navigationBar.barStyle = UIBarStyle.Black
        self.presentViewController(picker, animated: true, completion: nil)
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
    
    @IBAction func viewTypeCancelTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.ViewTypeCancel.alpha = 0
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
            }) { (finished) -> Void in
                self.ViewTypeParent.hidden = true
                //self.ViewTypeParent?.removeFromSuperview()
            }
        }

    }
    @IBAction func viewTypeCancelPost(sender: AnyObject) {
        self.viewTypeCancelTapped(self)
    }
    @IBAction func postCommentWedTapped(sender: AnyObject) {
        let commentToSend = PostCommentRequest(text: commentTextView.text, image: nil ,type: "link",url: nil, imageWidth: 0, imageHeight: 0)
        let createLinkPostVC = CreateURLPostViewController()
        commentToSend.postCommentId = post!.postId!
        createLinkPostVC.comment = commentToSend
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        self.viewTypeCancelTapped(self)
        print("Post link button pressed")
    }
    @IBOutlet weak var postCommentPhotoTapped: UIButton!
    @IBAction func postCommentTextTapped(sender: AnyObject) {
        self.viewTypeCancelTapped(self)
    }
    @IBAction func postCommentPhotoTapped(sender: AnyObject) {
        self.viewTypeCancelTapped(self)
        self.overlayView = UIView()
        self.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.overlayView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
        UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView)
        
        self.chooseSoureTypeView = ChooseSourceTypeView.instanceFromNib()
        self.chooseSoureTypeView.frame = CGRectMake(0, 0, 300, 200)
        self.chooseSoureTypeView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height/2.0)
        self.chooseSoureTypeView.delegate = self
        UIApplication.sharedApplication().keyWindow?.addSubview(self.chooseSoureTypeView!)
        
        self.chooseSoureTypeView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(0.1, animations: {
            self.chooseSoureTypeView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            UIView.animateWithDuration(0.05, animations: {
                self.chooseSoureTypeView.transform = CGAffineTransformIdentity
            }) { (finished) in
            }
        }) { (finished) in
            
        }

    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func postCommentTapped(sender: AnyObject) {
        print("send message pressed")
        commentTextView.resignFirstResponder()
        if commentTextView.text != "" && commentTextView.text != "Write a comment..." {
            SVProgressHUD.showWithStatus("Sending comment")
            var type : String? = "text"
            var intWidth :Int? = 0
            var intHeight : Int? = 0
            if(chosenImage != nil)
            {
                //let screenWidth = screenSize.width - 10
                //var radio : CGFloat? = CGFloat(screenWidth/(self.chosenImage?.size.width)!)
                
                intWidth = Int((self.chosenImage?.size.width)!)
                intHeight = Int((self.chosenImage?.size.height)!)
                
                type = "image"
            }
            let commentToSend = PostCommentRequest(text: commentTextView.text, image: self.chosenImage ,type: type,url: nil, imageWidth: intWidth, imageHeight: intHeight)
            networkController.createCommentUpdate(post!.postId!, postComment: commentToSend, completionHandler: { (comment, error) -> () in
                if error == nil {
                    if comment?.postCommentId != nil {
                        self.chosenImage = nil
                        self.chosenImageContainer.hidden = true
                        self.chosenImageContainer.subviews.forEach({ $0.removeFromSuperview() })
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
                            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.post!.postComments!.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
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
}
