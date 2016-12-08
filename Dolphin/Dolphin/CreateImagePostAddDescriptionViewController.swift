//
//  CreateImagePostAddDescriptionViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
//import KSTokenView
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class CreateImagePostAddDescriptionViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, KSTokenViewDelegate {

    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var tableViewPostDetails: UITableView!
    
    var postImage: UIImage?
    // if this var is set, I'm creating a text post from a POD
    var podId: Int?
    let tags: Array<String> = List.names()
    var mPost : Post?
    var comment : PostCommentRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        setRightButtonItemWithText("Post", target: self, action: #selector(CreateImagePostAddDescriptionViewController.postButtonTouchUpInside))
        self.edgesForExtendedLayout     = UIRectEdge()
        title                           = "Add description"
        tableViewPostDetails.delegate   = self
        tableViewPostDetails.dataSource = self
        tableViewPostDetails.tableFooterView = UIView(frame: CGRect.zero)
        registerCells()
        tableViewPostDetails.reloadData()
        
        if(mPost != nil)
        {
            
        }
    }
    
    // MARK: - Actions
    func postButtonTouchUpInside() {

        let cellInfo = tableViewPostDetails.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostAddDescriptionTableViewCell
        
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

        if title == nil || title?.characters.count <= 0 {
            Utils.presentAlertMessage(nil, message: Constants.Messages.PostTitleErrorMsg, cancelActionText: "Ok", presentingViewContoller: self)
            return
        }
        
        SVProgressHUD.show(withStatus: "Posting")
        DispatchQueue.main.async {
            // do your stuff here
            // crate the image pod
            
            var newWidth: CGFloat
            if self.postImage?.size.width < Constants.Globals.ImageMaxWidth {
                newWidth = self.postImage!.size.width
            } else {
                newWidth = Constants.Globals.ImageMaxWidth
            }
            
            let resizedImage = Utils.resizeImage(self.postImage!, newWidth: newWidth)
            if(self.mPost == nil)
            {
            let post = Post(user: nil, image: nil, imageData: resizedImage, imageWidth: Float(resizedImage.size.width), imageHeight: Float(resizedImage.size.height), type: PostType(name: "image"), topics: topics, link: nil, imageUrl: nil, title: title, text: description, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil, PODId: self.podId)
            
            self.networkController.createPost(post, completionHandler: { (post, error) -> () in
                if error == nil {
                    if post?.postId != nil {
                        // everything worked ok
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notifications.CreatedPost), object: nil, userInfo: ["post":post!])
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        // there was an error saving the post
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    var alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            }
            else{
                let post = PostRequest(image: nil, imageData: resizedImage, imageWidth: Float(resizedImage.size.width), imageHeight: Float(resizedImage.size.height), type: "image", topics: topics, link: nil, imageUrl: nil, title: title, text: description, PODId: self.podId, PostId: self.mPost!.postId)
                
                self.networkController.updatePost(post, completionHandler: { (post, error) -> () in
                    if error == nil {
                        if post?.postId != nil {
                            // everything worked ok
                            //NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPost, object: nil, userInfo: ["post":post!])
                            //self.navigationController?.popToRootViewControllerAnimated(true)
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
                        } else {
                            // there was an error saving the post
                        }
                        SVProgressHUD.dismiss()
                        
                    } else {
                        SVProgressHUD.dismiss()
                        let errors: [String]? = error!["errors"] as? [String]
                        var alert: UIAlertController
                        if errors != nil && errors![0] != "" {
                            alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .alert)
                        } else {
                            alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                        }
                        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CreatePostAddDescriptionTableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostAddDescriptionTableViewCell") as? CreatePostAddDescriptionTableViewCell
            if cell == nil {
                cell = CreatePostAddDescriptionTableViewCell()
            }
            cell?.textFieldPostTitle.delegate = self
            cell?.textViewDescription.delegate = self
            cell?.postTagsTextView.delegate    = self
            if(mPost != nil)
            {
                cell?.textFieldPostTitle.text = self.mPost?.postHeader
            }

            cell?.configureWithImage(false, postImage: postImage, postURL: nil, postImageURL: nil)
        }
        cell?.contentView.isUserInteractionEnabled = false
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.frame.height - (self.navigationController?.navigationBar.frame.size.height)! + 50.0)
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewPostDetails.register(UINib(nibName: "CreatePostAddDescriptionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CreatePostAddDescriptionTableViewCell")
        
    }
    
    // MARK: UITextField Delegate.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableViewPostDetails.setContentOffset(CGPoint(x: 0.0, y: 200.0), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableViewPostDetails.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: UITextView Delegate.
    func textViewDidBeginEditing(_ textView: UITextView) {
        tableViewPostDetails.setContentOffset(CGPoint(x: 0.0, y: 200.0), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        tableViewPostDetails.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func tokenView(_ token: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        var data: Array<String> = []
        for value: String in tags {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)
            }
        }
        completion!(data as Array<AnyObject>)
    }
    
    func tokenView(_ token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
    
    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        tableViewPostDetails.setContentOffset(CGPoint(x: 0.0, y: 400.0), animated: true)
    }
    
    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        tableViewPostDetails.setContentOffset(CGPoint.zero, animated: true)
    }
}
