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
    var podId: Int?
    
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
        setRightButtonItemWithText("Next", target: self, action: "nextButtonTouchUpInside")
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
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        postImagePreviewImageView.image = image
        postImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Actions
    
    func nextButtonTouchUpInside() {
        let addDescriptionVC = CreateImagePostAddDescriptionViewController()
        if postImage == nil {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "You have to select an image", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            addDescriptionVC.postImage = postImage
            addDescriptionVC.podId = podId
            navigationController?.pushViewController(addDescriptionVC, animated: true)
        }
    }
    

}
