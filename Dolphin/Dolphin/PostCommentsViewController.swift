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
    let screenSize: CGRect = UIScreen.main.bounds
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    
    init(post: Post) {
        super.init(nibName: "PostCommentsViewController", bundle: nil)
        self.post = post
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadComments(true)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        tableView.register(UINib(nibName: "PostCommentOddTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentOddTableViewCell")
        tableView.register(UINib(nibName: "PostCommentEvenTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentEvenTableViewCell")
        tableView.register(UINib(nibName: "PostCommentImageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentImageTableViewCell")
        tableView.register(UINib(nibName: "PostCommentImageLeftTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCommentImageLeftTableViewCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 10
        self.ViewTypeParent.isHidden = true

    }
    
    func setAppearance() {
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
        let viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTapRecognizer)
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.postComments!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
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
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Header for comments
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let headerImage = UIImageView(frame: CGRect(x: self.view.frame.size.width * 3 / 8.0, y: 5, width: self.view.frame.size.width / 4.0, height: 20))
        headerView.backgroundColor = UIColor.clear
        headerImage.backgroundColor = UIColor.clear
        headerImage.contentMode = .scaleAspectFit
        headerImage.image = UIImage(named: "CommentsTitleImage")
        headerView.addSubview(headerImage)
        return headerView
    }
    
    // MARK: - Keyboard management
    
    override func keyboardWillShow(_ notification: Foundation.Notification) {
        print("Keyboard appeared")
        if let userInfo = notification.userInfo {
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
    
    func viewTapped() {
        commentTextView.resignFirstResponder()
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
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.ViewTypeParent?.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.ViewTypeParent.isHidden = false
                self.ViewTypeCancel.alpha = 0.4
            })
        }) 
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

        chosenImageContainer.isHidden = false
        chosenImageView.image = chosenImage!
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismiss(animated: true, completion: nil)
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
    
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
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
    
    @IBAction func viewTypeCancelTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.ViewTypeCancel.alpha = 0
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
            }, completion: { (finished) -> Void in
                self.ViewTypeParent.isHidden = true
                //self.ViewTypeParent?.removeFromSuperview()
            }) 
        }) 

    }
    @IBAction func viewTypeCancelPost(_ sender: AnyObject) {
        self.viewTypeCancelTapped(self)
    }
    @IBAction func postCommentWedTapped(_ sender: AnyObject) {
        let commentToSend = PostCommentRequest(text: commentTextView.text, image: nil ,type: "link",url: nil, imageWidth: 0, imageHeight: 0)
        let createLinkPostVC = CreateURLPostViewController()
        commentToSend.postCommentId = post!.postId!
        createLinkPostVC.comment = commentToSend
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        self.viewTypeCancelTapped(self)
        print("Post link button pressed")
    }
    @IBOutlet weak var postCommentPhotoTapped: UIButton!
    @IBAction func postCommentTextTapped(_ sender: AnyObject) {
        self.viewTypeCancelTapped(self)
    }
    @IBAction func postCommentPhotoTapped(_ sender: AnyObject) {
        self.viewTypeCancelTapped(self)
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
    
    @IBAction func postCommentTapped(_ sender: AnyObject) {
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
                            self.tableView.scrollToRow(at: IndexPath(row: self.post!.postComments!.count - 1, section: 0), at: .bottom, animated: true)
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
}
