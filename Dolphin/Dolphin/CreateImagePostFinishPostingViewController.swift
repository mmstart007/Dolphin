//
//  CreateImagePostFinishPostingViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/18/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreateImagePostFinishPostingViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseSourceTypeViewDelegate {

    
    var postImage: UIImage?
    var picker: UIImagePickerController = UIImagePickerController()
    var podId: Int?
    var mPost : Post?
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    
    @IBOutlet weak var postImagePreviewImageView: UIImageView!
    
    init(image: UIImage?) {
        super.init(nibName: "CreateImagePostFinishPostingViewController", bundle: nil)
        postImage = image;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightButtonItemWithText("Next", target: self, action: #selector(nextButtonTouchUpInside))
        self.edgesForExtendedLayout = .None
        title = "New Post"
        if(mPost != nil)
        {
            title = "Edit Post"
        }
        
        if postImage != nil {
            postImagePreviewImageView.image = postImage
            postImagePreviewImageView.contentMode = .ScaleAspectFit
        } else {
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
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
            addDescriptionVC.mPost = mPost;
            navigationController?.pushViewController(addDescriptionVC, animated: true)
        }
    }
    
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
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
    
    func selectedPhotoGallery() {
        self.closedDialog()
        
        self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.picker.delegate   = self
        self.picker.allowsEditing = true
        self.picker.navigationBar.tintColor = UIColor.whiteColor()
        self.picker.navigationBar.barStyle = UIBarStyle.Black
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnSelectPicture: UIButton!

    @IBAction func btnSelecPictureTapped(sender: AnyObject) {
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
}
