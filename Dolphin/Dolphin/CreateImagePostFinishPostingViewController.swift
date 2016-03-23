//
//  CreateImagePostFinishPostingViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/18/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class CreateImagePostFinishPostingViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let networkController = NetworkController.sharedInstance
    
    var postImage: UIImage?
    var picker: UIImagePickerController = UIImagePickerController()
    
    @IBOutlet weak var postImagePreviewImageView: UIImageView!
    
    init(image: UIImage?) {
        super.init(nibName: "CreateImagePostFinishPostingViewController", bundle: nil)
        postImage = image
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightButtonItemWithText("Post", target: self, action: "postButtonTouchUpInside")
        self.edgesForExtendedLayout = .None
        title = "New Post"
        
        if postImage != nil {
            postImagePreviewImageView.image = postImage
            postImagePreviewImageView.contentMode = .ScaleAspectFit
        } else {
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.delegate   = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        postImagePreviewImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func postButtonTouchUpInside() {
        print("postButtonTouchUpInside")

        var newWidth: CGFloat
        if self.postImage?.size.width < 414 {
            newWidth = self.postImage!.size.width
        } else {
            newWidth = 414
        }
        let resizedImage = Utils.resizeImage(self.postImage!, newWidth: newWidth)
        
        // crate the pod
        let post = Post(user: nil, image: nil, imageData: resizedImage, type: PostType(name: "image"), topics: nil, link: nil, imageUrl: nil, title: nil, text: nil, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil)
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
        
        
    }
    

}
