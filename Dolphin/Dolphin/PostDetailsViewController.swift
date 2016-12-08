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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PostDetailsViewController : DolphinViewController, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,ImageCropViewControllerDelegate, PostDetailsTopicsAndViewsTableViewCellDelegate,ChooseSourceTypeViewDelegate {

    @IBOutlet weak var ViewTypeCancel: UIButton!
    @IBOutlet weak var ViewTypeParent: UIView!
    let networkController = NetworkController.sharedInstance
    let commentTextViewPlaceHolder: String! = "Write a comment..."
    let picker = UIImagePickerController()
    
    var post: Post?
    var needToReloadPost = true
    var contentOffset: CGFloat = 0
    var actionMenu: UIView? = nil
    var chosenImage: UIImage? = nil
    var pod : POD?
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    let screenSize: CGRect = UIScreen.main.bounds
    
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
        tableView.register(UINib(nibName: "PostDetailHeaderTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostDetailHeaderTableViewCell")
        tableView.register(UINib(nibName: "PostCommentOddTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.register(UINib(nibName: "PostCommentEvenTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.register(UINib(nibName: "PostCommentImageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentImageTableViewCell")
        tableView.register(UINib(nibName: "PostCommentImageLeftTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentImageLeftTableViewCell")
        tableView.register(UINib(nibName: "PostDetailsTopicsAndViewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostDetailsTopicsAndViewsTableViewCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 10
        
        addKeyboardObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadPost()
        if needToReloadPost {
        }
        else {
            commentTextView.text = ""
            loadComments(true)
        }
    }
    
    func setAppearance() {
        ViewTypeParent.isHidden = true
        self.edgesForExtendedLayout = UIRectEdge()
        title = "Dolphin"
        setBackButton()
        chosenImageContainer.isHidden         = true
        commentTextView.layer.cornerRadius  = 10
        commentTextView.layer.masksToBounds = true
        commentTextView.layer.borderWidth   = 1
        commentTextView.layer.borderColor   = UIColor.lightGray.cgColor
        commentTextView.backgroundColor     = UIColor.lightText
        commentTextView.delegate            = self
        commentTextView.text                = commentTextViewPlaceHolder
        commentTextView.textColor           = UIColor.darkGray
        let viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        viewTapRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(viewTapRecognizer)
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func setNavBarButtons() {

        // comments new windows
        if(self.post?.postUser?.id == networkController.currentUserId) {
            let customVieweditButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customVieweditButton.setImage(UIImage(named: "ic_edit"), for: UIControlState())
            customVieweditButton.setImage(UIImage(named: "ic_edit"), for: .highlighted)
            customVieweditButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
            let edtBarButton        = UIBarButtonItem(customView: customVieweditButton)

            
            let customViewRemoveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewRemoveButton.setImage(UIImage(named: "garbage"), for: UIControlState())
            customViewRemoveButton.setImage(UIImage(named: "garbage"), for: .highlighted)
            customViewRemoveButton.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
            let removeBarButton        = UIBarButtonItem(customView: customViewRemoveButton)
            
            let customViewActionButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), for: UIControlState())
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), for: .highlighted)
            customViewActionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
            let actionBarButton         = UIBarButtonItem(customView: customViewActionButton)
            
            navigationItem.rightBarButtonItems = [actionBarButton, removeBarButton, edtBarButton]
        }

        else {
            let customViewActionButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), for: UIControlState())
            customViewActionButton.setImage(UIImage(named: "ActionNavBarIcon"), for: .highlighted)
            customViewActionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
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
    
    func editButtonPressed() {
       
        let type : String = (self.post!.postType?.name)!
        if(type.isEmpty) {return}
        
        if(type.contains("text"))
        {
            let createTextPostVC = CreateTextPostViewController()
            //createTextPostVC.pod = pod
            createTextPostVC.isPresentMode = true
            createTextPostVC.mPost = self.post!
            if(self.pod != nil)
            {
                createTextPostVC.pod = self.pod;
            }
            let textPostNavController = UINavigationController(rootViewController: createTextPostVC)
            present(textPostNavController, animated: true, completion: nil)
        } else if(type.contains("image"))
        {
            if(self.post?.postImage == nil)
            {
                return
            }
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let data = try? Data(contentsOf: URL(string: (self.post?.postImage?.imageURL!)!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                DispatchQueue.main.async(execute: {
                    if(data != nil)
                    {
                        self.post?.postImageData = UIImage(data: data!)
                        let finishImagePostVC = CreateImagePostFinishPostingViewController(image: self.post!.postImageData)
                        finishImagePostVC.mPost = self.post!
                        if(self.pod != nil)
                        {
                            finishImagePostVC.podId = self.pod?.id;
                        }
                        self.navigationController?.pushViewController(finishImagePostVC, animated: true)
                    }
                    
                });
            }

            
        }
        else if(type.contains("link"))
        {
            let createLinkPostVC = CreateURLPostViewController()
            if(pod != nil)
            {
                createLinkPostVC.podId = pod?.id
            }
            createLinkPostVC.mPost = self.post!
            if(self.pod != nil)
            {
                createLinkPostVC.podId = self.pod?.id;
            }
            self.navigationController?.pushViewController(createLinkPostVC, animated: true)
        }
    }
    
    // MARK: NavBar Actions and Action Menu
    func removeButtonPressed() {
        let alertController = UIAlertController(title: nil, message: Constants.Messages.RemovePostMsg, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
            SVProgressHUD.show()
            let postIdString = String(self.post!.postId!)
            self.networkController.deletePost(postIdString) { (error) -> () in
                SVProgressHUD.dismiss()
                if error == nil {
                    print("post deleted")
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notifications.DeletedPost), object: nil, userInfo: ["post":self.post!])
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func actionButtonPressed() {
        if post?.postType?.name == "link" {
            let imageURL = URL(string: (post?.postLink?.imageURL)!)
            
            let shareText = (post?.postText)! + "\n" + Constants.Messages.ShareSuffix + "\n" + Constants.iTunesURL
            let manager = SDWebImageManager.shared()
            
            manager?.downloadImage(with: imageURL, options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText, image!], applicationActivities: nil)
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
            
            let imageURL = URL(string: (post?.postImage?.imageURL)!)
            let manager = SDWebImageManager.shared()
            let shareText = (post?.postHeader)! + "\n" + (post?.postText)! + "\n" + Constants.Messages.ShareSuffix + "\n" + Constants.iTunesURL
            
            manager?.downloadImage(with: imageURL, options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                if error == nil {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText, image!], applicationActivities: nil)
                    self.showActivityController(shareVC)
                } else {
                    let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    self.showActivityController(shareVC)
                }
            })
        }
    }
    
    func showActivityController(_ shareVC: UIActivityViewController) {
        shareVC.completionWithItemsHandler = {(activityType, success, items, error) in
            if !success {
                print("cancelled")
            } else {
                var shareType = Constants.ShareType.Share_Other
                if activityType == UIActivityType.mail {
                    shareType = Constants.ShareType.Share_Mail
                }
                else if activityType == UIActivityType.message {
                    shareType = Constants.ShareType.Share_SMS
                }
                else if activityType == UIActivityType.postToFacebook {
                    shareType = Constants.ShareType.Share_Facebook
                }
                else if activityType == UIActivityType.postToTwitter {
                    shareType = Constants.ShareType.Share_Twitter
                }
                
                self.networkController.createPostShare("\(self.post!.postId!)", type:shareType, completionHandler: { (error) -> () in
                    if error == nil {
                        
                    } else {
                    }
                })
            }
        }
        self.present(shareVC, animated: true, completion: nil)
    }
    
    func setupActionMenuFields() {
        if self.actionMenu != nil {
            firstActionButton.layer.cornerRadius  = 5
            firstActionButton.layer.borderWidth   = 1
            firstActionButton.layer.borderColor   = UIColor.darkGray.cgColor

            fourthActionButton.layer.cornerRadius = 5
            fourthActionButton.layer.borderWidth  = 1
            fourthActionButton.layer.borderColor  = UIColor.darkGray.cgColor

            sixthActionButton.layer.cornerRadius  = 5
            sixthActionButton.layer.borderWidth   = 1
            sixthActionButton.layer.borderColor   = UIColor.darkGray.cgColor

            secondActionButton.layer.cornerRadius = 5
            thirdActionButton.layer.cornerRadius  = 5
            fifthActionButton.layer.cornerRadius  = 5
        }
    }
    
    @IBAction func closePostActionViewTouchUpInside(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.actionMenuBackground.alpha = 0
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.shared.keyWindow?.frame.size.height)!, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
                    }, completion: { (finished) -> Void in
                        self.actionMenu?.removeFromSuperview()
                }) 
        }) 
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
            SVProgressHUD.show(withStatus: "Loading")
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
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            
            SVProgressHUD.show(withStatus: "Loading")
            networkController.deleteLike("\(post!.postId!)", completionHandler: { (error) -> () in
                if error == nil {
                    self.post?.postNumberOfLikes = (self.post?.postNumberOfLikes)! - 1
                    self.post?.isLikedByUser = false
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        }
        print("Like Button Pressed")
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return (post?.postComments!.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostDetailHeaderTableViewCell") as? PostDetailHeaderTableViewCell
            if cell == nil {
                cell = PostDetailHeaderTableViewCell()
            }
            (cell as? PostDetailHeaderTableViewCell)?.configureWithPost(post!)
            
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostDetailsTopicsAndViewsTableViewCell") as? PostDetailsTopicsAndViewsTableViewCell
            if cell == nil {
                cell = PostDetailsTopicsAndViewsTableViewCell()
            }
            cell?.contentView.isUserInteractionEnabled = false
            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.configureWithPost(post!)
            (cell as? PostDetailsTopicsAndViewsTableViewCell)?.delegate = self
        } else {
            let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
            if indexPath.row % 2 == 1 {
                if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
                {
                    cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentImageTableViewCell") as? PostCommentImageTableViewCell
                    if cell == nil {
                        cell = PostCommentImageTableViewCell()
                    }
                    (cell as? PostCommentImageTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                    (cell as? PostCommentImageTableViewCell)?.controller = self
                    (cell as? PostCommentImageTableViewCell)?.mPost = self.post

                }
                else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentEvenTableViewCell") as? PostCommentEvenTableViewCell
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
                    cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentImageLeftTableViewCell") as? PostCommentImageLeftTableViewCell
                    if cell == nil {
                        cell = PostCommentImageLeftTableViewCell()
                    }
                    (cell as? PostCommentImageLeftTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                    (cell as? PostCommentImageLeftTableViewCell)?.controller = self
                    (cell as? PostCommentImageLeftTableViewCell)?.mPost = self.post
                }
                else{
                cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentOddTableViewCell") as? PostCommentOddTableViewCell
                if cell == nil {
                    cell = PostCommentOddTableViewCell()
                }
                
                (cell as? PostCommentOddTableViewCell)?.configureWithPostComment(post!.postComments![indexPath.row])
                (cell as? PostCommentOddTableViewCell)?.controller = self
                (cell as? PostCommentOddTableViewCell)?.mPost = self.post
                }
            }
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    
    private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 2)
        {
            if(self.post!.postComments?.count > 0)
            {
                let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
                if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
                {
                    
                    let screenWidth = screenSize.width - 10
                    let radio : CGFloat? = CGFloat(screenWidth/(commentInfo?.postLink != nil ? commentInfo?.postLink?.imageWidth : commentInfo?.postImage?.imageWidth)!)
                    let height:CGFloat? = CGFloat((commentInfo?.postLink != nil ? commentInfo?.postLink?.imageHeight : commentInfo?.postImage?.imageHeight!)!*radio!)
                    
                    if(!(height?.isNaN)!)
                    {
                        return height!
                    }
                    return 350
                }
                return UITableViewAutomaticDimension
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        // Adjust views of image
        if indexPath.section == 0 {
            (cell as? PostDetailHeaderTableViewCell)?.adjustCellViews()
        }
        // Adjust views of comment cells
        if indexPath.section == 2 {
            let commentInfo: PostComment? = self.post!.postComments![indexPath.row]
            if indexPath.row % 2 == 0 {
                if(commentInfo?.postLink != nil || commentInfo?.postImage != nil)
                {
                    (cell as? PostCommentImageTableViewCell)?.adjustCellViews()
                }
                else {
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
        } else if indexPath.section == 1 {
//            (cell as? PostDetailsTopicsAndViewsTableViewCell)!.collectionView.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
        }
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Only header for comments section
        if section == 2 {
            return 30
        } else {
            return 0.0
        }
    }
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Only header for comments section
        if section == 2 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
            let headerImage = UIImageView(frame: CGRect(x: self.view.frame.size.width * 3 / 8.0, y: 5, width: self.view.frame.size.width / 4.0, height: 20))
            headerView.backgroundColor = UIColor.clear
            headerImage.backgroundColor = UIColor.clear
            headerImage.contentMode = .scaleAspectFit
            headerImage.image = UIImage(named: "CommentsTitleImage")
            headerView.addSubview(headerImage)
            return headerView
        } else {
            return UIView()
        }
    }
    
    // MARK: Tableview delegate
    
    private func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if indexPath.section == 2 {
            let postCommentsVC  = PostCommentsViewController(post: post!)
            navigationController?.pushViewController(postCommentsVC, animated: true)
        }
    }
    
    // MARK: Keyboard management
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillAppear(_ sender: Foundation.Notification) {
        print("Keyboard appeared")
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                writeCommentBottomConstraint.constant = keyboardSize.height
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func keyboardWillHide(_ notification: Foundation.Notification) {
        print("Keyboard hidden")
        writeCommentBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
    // MARK UItextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == commentTextViewPlaceHolder {
            textView.text = ""
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = commentTextViewPlaceHolder
        }
        textView.resignFirstResponder()
    }
    
    // Photo actions
    
    @IBAction func selectImageButtonTouchUpInside(_ sender: AnyObject) {
        
        picker.delegate = self
        let alert = UIAlertController(title: "Lets get a picture", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.default) { (alert) -> Void in
            self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.picker.navigationBar.isTranslucent = false
            self.picker.navigationBar.barTintColor = UIColor.blueDolphin()
            self.present(self.picker, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default) { (alert) -> Void in
                print("Take Photo")
                self.picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.picker, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func removeImageFromCommentButtonTouchUpInside(_ sender: AnyObject) {
        chosenImage = nil
        chosenImageView.image = nil
        chosenImageContainer.isHidden = true
    }
    
    //MARK: Images Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo")
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let screenWidth = (screenSize.width - 10)*2
        let radio : CGFloat? = CGFloat(screenWidth/(self.chosenImage?.size.width)!)
        
        let intWidth :CGFloat? = CGFloat(screenWidth)
        let intHeight :CGFloat? = CGFloat((self.chosenImage?.size.height)!*radio!)

        chosenImage = self.ResizeImage(chosenImage!, targetSize: CGSize(width: intWidth!, height: intHeight!))
        chosenImageContainer.isHidden = false
        if(chosenImageView != nil)
        {
            chosenImageView.image = chosenImage!
        }
        dismiss(animated: true, completion: nil)
        /*var imageOriginalSelected : UIImage? = info[UIImagePickerControllerOriginalImage] as! UIImage
        let cropController = ImageCropViewController(image: imageOriginalSelected, cropRect: CGRectZero)
        cropController.delegate = self
        navigationController?.pushViewController(cropController, animated: true)
        dismissViewControllerAnimated(true, completion: nil)*/
    }
    
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismiss(animated: true, completion: nil)
    }
    
    
    func imageCropViewControllerSuccess(_ controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!, cropRect: CGRect) {
        //selectedCropRect = cropRect
        //imageSelected = croppedImage
        //podImageView.image = croppedImage
        chosenImageContainer.isHidden = false
        chosenImage = croppedImage!
        chosenImageView.image = croppedImage!
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewControllerDidCancel(_ controller: UIViewController!) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Auxiliary methods
    
    func loadPost() {
        SVProgressHUD.show(withStatus: "Loading")
        networkController.getPostById(String(post!.postId!), completionHandler: { (post, error) in
            if error == nil {
                self.post = post
                self.loadComments(false)
            }
            else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func loadComments(_ showIndicator:Bool) {
        if showIndicator {
            SVProgressHUD.show(withStatus: "Loading")
        }
        
        networkController.getPostComments(String(post!.postId!)) { (postComments, error) -> () in
            if error == nil {
                self.post?.postComments = postComments
                self.tableView.reloadData()
                
                //Add Open History.
                self.networkController.createPostOpen(String(self.post!.postId!), completionHandler: { (error) in
                    print(error!);
                })
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func postMessageTouchUpInside(_ sender: AnyObject) {
        print("send message pressed")
        commentTextView.resignFirstResponder()
        if commentTextView.text != "" && commentTextView.text != "Write a comment..." {
            SVProgressHUD.show(withStatus: "Sending comment")
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
                        self.chosenImageContainer.isHidden = true
                        self.chosenImageContainer.subviews.forEach({ $0.removeFromSuperview() })
                        // add the comment returned locally
                        self.post?.postComments?.append(comment!)
                        // everything worked ok, reload the table of comments
                        self.tableView.reloadData()
                        // reset the field
                        self.commentTextView.text = ""
                        // after a delay, scroll the table to the last comment
                        let delay = 0.1 * Double(NSEC_PER_SEC)
                        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: time, execute: {
                            self.tableView.scrollToRow(at: IndexPath(row: self.post!.postComments!.count - 1, section: 2), at: .bottom, animated: true)
                        })
                    } else {
                        print("there was an error saving the post")
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
            
        } else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "The message can't be empty!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Topic
    func tapTopic(_ topic: Topic?) {
        let topicPost = TagPostsViewController(likes: false)
        topicPost.selectedTopic = topic
        navigationController?.pushViewController(topicPost, animated: true)
    }
    
    
    @IBAction func btnCloseTapped(_ sender: AnyObject) {
        self.ViewTypeCancelTapped(self)
    }
    
    @IBAction func postPhotoCommentTapped(_ sender: AnyObject) {
        self.ViewTypeCancelTapped(self)
        self.overlayView = UIView()
        self.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.overlayView.frame = (UIApplication.shared.keyWindow?.frame)!
        UIApplication.shared.keyWindow?.addSubview(self.overlayView)
        
        self.chooseSoureTypeView = ChooseSourceTypeView.instanceFromNib()
        self.chooseSoureTypeView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        self.chooseSoureTypeView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height/2.0)
        self.chooseSoureTypeView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(self.chooseSoureTypeView!)
        
        self.chooseSoureTypeView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.1, animations: {
            self.chooseSoureTypeView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.05, animations: {
                self.chooseSoureTypeView.transform = CGAffineTransform.identity
            }, completion: { (finished) in
            }) 
        }, completion: { (finished) in
            
        }) 

    }
    
    func nextButtonTouchUpInside() {
        let addDescriptionVC = CreateImagePostAddDescriptionViewController()
        if chosenImage == nil {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "You have to select an image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            addDescriptionVC.postImage = chosenImage
            //addDescriptionVC.podId = podId
            addDescriptionVC.mPost = self.post;
            navigationController?.pushViewController(addDescriptionVC, animated: true)
        }
    }
    
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
    }
    
    func selectedCamera() {
        self.closedDialog()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else {
            Utils.presentAlertMessage("Error", message: "Device has no camera", cancelActionText: "Ok", presentingViewContoller: self)
        }
    }
    
    func selectedPhotoGallery() {
        self.closedDialog()
        
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.picker.delegate   = self
        self.picker.allowsEditing = true
        self.picker.navigationBar.tintColor = UIColor.white
        self.picker.navigationBar.barStyle = UIBarStyle.black
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func postTextCommentTapped(_ sender: AnyObject) {
        self.ViewTypeCancelTapped(self)
    }
    
    @IBAction func postWedCommentTapped(_ sender: AnyObject) {
        let commentToSend = PostCommentRequest(text: commentTextView.text, image: nil ,type: "link",url: nil, imageWidth: 0, imageHeight: 0)
        let createLinkPostVC = CreateURLPostViewController()
        commentToSend.postCommentId = post!.postId!
        createLinkPostVC.comment = commentToSend
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        self.ViewTypeCancelTapped(self)
        print("Post link button pressed")
    }
    
    @IBAction func showCommentTypeTapped(_ sender: AnyObject) {
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.ViewTypeParent?.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.ViewTypeParent.isHidden = false
                self.ViewTypeCancel.alpha = 0.4
            })
        }) 
    }
    @IBAction func ViewTypeCancelTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.ViewTypeCancel.alpha = 0
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.shared.keyWindow?.frame.size.height)!, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
            }, completion: { (finished) -> Void in
                self.ViewTypeParent.isHidden = true
                //self.ViewTypeParent?.removeFromSuperview()
            }) 
        }) 
    }
}
