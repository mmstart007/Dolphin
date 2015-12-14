//
//  CreateImagePostViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/14/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreateImagePostViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imagePreviewImageView: UIImageView!
    var tapToChooseImageLabel: UILabel?
    
    let picker = UIImagePickerController()
    var chosenImage: UIImage? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if chosenImage != nil {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            if tapToChooseImageLabel == nil {
                tapToChooseImageLabel = UILabel(frame: CGRect(x: 0, y: (self.view.frame.size.height / 2) - 25, width: self.view.frame.size.width, height: 50))
                tapToChooseImageLabel?.font          = UIFont.systemFontOfSize(18)
                tapToChooseImageLabel?.textAlignment = .Center
                tapToChooseImageLabel?.textColor     = UIColor.lightGrayColor()
                tapToChooseImageLabel?.text          = "Tap on the screen to choose an Image"
                self.view.addSubview(tapToChooseImageLabel!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Post"
        setRightButtonItemWithText("Post", target: self, action: "postImage:")
        navigationItem.rightBarButtonItem?.enabled = false
        self.edgesForExtendedLayout = .None
        imagePreviewImageView.backgroundColor = UIColor.clearColor()
        imagePreviewImageView.contentMode = .ScaleAspectFit
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "openImagePicker")
        self.view.addGestureRecognizer(imageTapGestureRecognizer)
        setBackButton()
    }
    
    // Photo actions
    
    func openImagePicker() {
        
        picker.delegate = self
        let alert = UIAlertController(title: "Lets get a picture", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
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
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Images Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePreviewImageView.image = chosenImage!
        imagePreviewImageView.backgroundColor = UIColor.clearColor()
        tapToChooseImageLabel?.removeFromSuperview()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Post image
    
    func postImage(sender: AnyObject?) {
        print("Post image button touched")
    }
    
}