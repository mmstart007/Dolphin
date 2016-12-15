//
//  CreateURLPostAddDescriptionViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class CreateURLPostAddDescriptionViewController: DolphinViewController, UITextFieldDelegate, UITextViewDelegate, KSTokenViewDelegate {

    var postImageURL: String?
    var postURL: String?
    
    @IBOutlet weak var imageViewPostImage: UIImageView!
    @IBOutlet weak var textFieldPostTitle: UITextField!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var postTagsTextView: KSTokenView!
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var constraintBottomSpaceOfScrollView: NSLayoutConstraint!

    // if this var is set, I'm creating a text post from a POD
    let tags: Array<String> = List.names()
    let networkController = NetworkController.sharedInstance
    var podId: Int?
    var mPost : Post?
    var comment : PostCommentRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightButtonItemWithText("Post", target: self, action: #selector(self.postButtonTouchUpInside))
        self.edgesForExtendedLayout     = UIRectEdge()
        title                           = "Add description"
        textViewDescription.placeholder = "Write your moment..."
        if(mPost != nil)
        {
            textFieldPostTitle.text = mPost?.postHeader
        }
        configureWithImage(true, postImage: nil, postURL: postURL, postImageURL: postImageURL)
    }
    
    func configureWithImage(_ isLink: Bool, postImage: UIImage?, postURL: String?, postImageURL: String?) {
        
        postTagsTextView.delegate         = self
        
        postTagsTextView.promptText       = ""
        postTagsTextView.placeholder      = ""
        postTagsTextView.maxTokenLimit    = 8//default is -1 for unlimited number of tokens
        postTagsTextView.style            = .rounded
        postTagsTextView.searchResultSize = CGSize(width: postTagsTextView.frame.width, height: 88)
        postTagsTextView.font             = UIFont.systemFont(ofSize: 14)
        postTagsTextView.backgroundColor = UIColor.clear
        for view in postTagsTextView.subviews {
            if view.isKind(of: UITextField.self) {
                
                let textField = view as? UITextField
                textField?.borderStyle = .none
                
            }
        }
        
        if(mPost != nil)
        {
            textFieldPostTitle.text = self.mPost?.postHeader
        }
        
        if isLink {
            let manager = SDWebImageManager.shared()
            _ = manager?.downloadImage(with: URL(string: postImageURL!), options: .refreshCached, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) in
                if error == nil {
                    self.imageViewPostImage.image = image
                } else {
                    self.imageViewPostImage.image = UIImage(named: "PostImagePlaceholder")
                }
            })
        } else {
            imageViewPostImage.image = postImage!
        }
        if isLink {
            textFieldPostTitle.text = postURL
            textFieldPostTitle.isUserInteractionEnabled = false
        } else {
            textFieldPostTitle.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Actions
    func postButtonTouchUpInside() {

        //Get Info.
        let description = textViewDescription.text
        
        let topicsStringArray = postTagsTextView.tokens()
        var topics: [Topic] = []
        if topicsStringArray != nil {
            for t in topicsStringArray! {
                topics.append(Topic(name: t.title))
            }
        }
        
        var imageWidth:Float = 0
        var imageHeight:Float = 0
        
        if let postImage = imageViewPostImage.image {
            imageWidth = Float(postImage.size.width)
            imageHeight = Float(postImage.size.height)
        }
        
        //if description != "" {
            let link = Link(url: postURL!, imageURL: postImageURL!)
            // crate the pod
        if(comment != nil)
        {
            SVProgressHUD.show(withStatus: "Sending comment")
            self.comment?.postImageHeight = Int(imageHeight)
            self.comment?.postImageWidth = Int(imageWidth)
            self.comment?.postCommentText = self.comment?.url
            
            networkController.createCommentUpdate(self.comment!.postCommentId!, postComment: self.comment!, completionHandler: { (comment, error) -> () in
                if error == nil {
                    if comment?.postCommentId != nil {
                        //self.navigationController?.popViewControllerAnimated(true)
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true);
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
        }
        else if(mPost == nil) {
            let post = Post(user: nil, image: nil, imageData: nil, imageWidth: imageWidth, imageHeight: imageHeight, type: PostType(name: "link"), topics: topics, link: link, imageUrl: nil, title: nil, text: description, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil, PODId: podId)
            SVProgressHUD.show(withStatus: "Posting")
            networkController.createPost(post, completionHandler: { (post, error) -> () in
                if error == nil {
                    
                    if post?.postId != nil {
                        // everything worked ok
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notifications.CreatedPost), object: nil, userInfo: ["post":post!])
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true);
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
            let post = PostRequest(image: nil, imageData: nil, imageWidth: imageWidth, imageHeight: imageHeight, type: "link", topics: topics, link: link, imageUrl: nil, title: nil, text: description, PODId: podId, PostId: self.mPost!.postId)
            SVProgressHUD.show(withStatus: "Posting")
            networkController.updatePost(post, completionHandler: { (post, error) -> () in
                if error == nil {
                    
                    if post?.postId != nil {
                        // everything worked ok
                        //NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPost, object: nil, userInfo: ["post":post!])
                        //self.navigationController?.popToRootViewControllerAnimated(true)
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true);
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
        /*} else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "Please, fill all the fields", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }*/
    }
    
    // MARK: - KSTokenView Delegate
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
    
    // MARK: - Keyboard Stack.
    override func keyboardWillShow(_ notification: Foundation.Notification) {
        
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            self.constraintBottomSpaceOfScrollView.constant = keyboardSize.height
            updateViewConstraints()
            self.scrollViewContainer.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
        }
    }
    
    override func keyboardWillHide(_ notification: Foundation.Notification) {
        self.constraintBottomSpaceOfScrollView.constant = 0
        updateViewConstraints()
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
    // MARK: - UITableView Datasource.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CreatePostAddDescriptionTableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostAddDescriptionTableViewCell") as? CreatePostAddDescriptionTableViewCell
            if cell == nil {
                cell = CreatePostAddDescriptionTableViewCell()
            }
            cell?.textFieldPostTitle.delegate = self
            cell?.textViewDescription.delegate = self
            cell?.postTagsTextView.delegate = self
            if(mPost != nil)
            {
                cell?.textFieldPostTitle.text = mPost?.postHeader
            }
            cell?.configureWithImage(true, postImage: nil, postURL: postURL, postImageURL: postImageURL)
        }
        cell?.contentView.isUserInteractionEnabled = false
        cell?.selectionStyle = .none
        return cell!
    } */
}
