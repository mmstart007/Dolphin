//
//  CreateImagePostFinishPostingViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/18/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreateImagePostFinishPostingViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}
