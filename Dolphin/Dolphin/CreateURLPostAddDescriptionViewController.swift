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

        let cellInfo = tableViewPostDetails.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? CreatePostAddDescriptionTableViewCell
        
        //Hide Keyboard
        cellInfo?.textViewDescription.resignFirstResponder()
        cellInfo?.textFieldPostTitle.resignFirstResponder()
        cellInfo?.postTagsTextView.resignFirstResponder()
        
        //Get Info.
        let description = cellInfo?.textViewDescription.text
        
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
        
        if description != "" {
            let link = Link(url: postURL!, imageURL: postImageURL!)
            // crate the pod
            let post = Post(user: nil, image: nil, imageData: nil, imageWidth: imageWidth, imageHeight: imageHeight, type: PostType(name: "link"), topics: topics, link: link, imageUrl: nil, title: nil, text: description, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil, PODId: podId)
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
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CreatePostAddDescriptionTableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("CreatePostAddDescriptionTableViewCell") as? CreatePostAddDescriptionTableViewCell
            if cell == nil {
                cell = CreatePostAddDescriptionTableViewCell()
            }
            cell?.textFieldPostTitle.delegate = self
            cell?.textViewDescription.delegate = self
            cell?.postTagsTextView.delegate = self
            cell?.configureWithImage(true, postImage: nil, postURL: postURL, postImageURL: postImageURL)
        }
        cell?.contentView.userInteractionEnabled = false
        cell?.selectionStyle = .None
        return cell!
    }
}
