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
        self.edgesForExtendedLayout = UIRectEdge()
        title = "New Post"
        if(mPost != nil)
        {
            title = "Edit Post"
        }
        
        if postImage != nil {
            postImagePreviewImageView.image = postImage
            postImagePreviewImageView.contentMode = .scaleAspectFit
        } else {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo")
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        postImagePreviewImageView.image = image
        postImage = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let _ = navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Actions
    
    func nextButtonTouchUpInside() {
        let addDescriptionVC = CreateImagePostAddDescriptionViewController()
        if postImage == nil {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "You have to select an image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
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
    
    @IBOutlet weak var btnSelectPicture: UIButton!

    @IBAction func btnSelecPictureTapped(_ sender: AnyObject) {
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
}
