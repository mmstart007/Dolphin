//
//  CreateURLPostAddDescriptionViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/25/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateURLPostAddDescriptionViewController: CreateImagePostAddDescriptionViewController {

    var postImageURL: String?
    var postURL: String?
    
    // MARK: - Actions
    
    override func postButtonTouchUpInside() {

        let cellInfo = tableViewPostDetails.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostAddDescriptionTableViewCell
        
        //Hide Keyboard
        cellInfo?.textViewDescription.resignFirstResponder()
        cellInfo?.textFieldPostTitle.resignFirstResponder()
        cellInfo?.postTagsTextView.resignFirstResponder()
        
        //Get Info.
        let description = ""//cellInfo?.textViewDescription.text
        
        let topicsStringArray = cellInfo?.postTagsTextView.tokens()
        var topics: [Topic] = []
        if topicsStringArray != nil {
            for t in topicsStringArray! {
                topics.append(Topic(name: t.title))
            }
        }
        
        var imageWidth:Float = 0
        var imageHeight:Float = 0
        
        if let postImage = cellInfo?.imageViewPostImage.image {
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
    }
}
