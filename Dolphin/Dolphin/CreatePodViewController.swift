//
//  CreatePodViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class CreatePodViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var leftCharactersLabel: UILabel!
    @IBOutlet weak var podNameTextField: UITextField!
    @IBOutlet weak var podDescriptionTextView: UITextView!
    @IBOutlet weak var switchIsPrivate: UISwitch!
    
    let networkController = NetworkController.sharedInstance
    let picker = UIImagePickerController()
    let maxNameCharacters = 20
    
    var imageSelected: UIImage?
    
    required init() {
        super.init(nibName: "CreatePodViewController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2
        cameraButton.layer.borderWidth = 1
        cameraButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        podDescriptionTextView.placeholder = "POD Description"
        podDescriptionTextView.placeholderColor = UIColor.lightGrayColor()
        podDescriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 0)
        
        podNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        leftCharactersLabel.text = String(format: "%li / %li", arguments: [(podNameTextField!.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!, maxNameCharacters])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightButtonItemWithText("Save", target: self, action: Selector("saveSettingsPressed:"))
        title = "Create a POD"
        
        membersCollectionView.registerNib(UINib(nibName: "UserImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "UserImageCollectionViewCell")
        membersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        membersCollectionView.dataSource = self
        membersCollectionView.delegate   = self
        
//        let tapViewGesture = UITapGestureRecognizer(target: self, action: "resignResponder")
//        self.view.addGestureRecognizer(tapViewGesture)
    }

    // MARK: Select POD Image
    
    @IBAction func selectImage(sender: AnyObject) {
        
        resignResponder()
        picker.delegate = self
        let alert = UIAlertController(title: "Choose a Picture", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        let libButton = UIAlertAction(title:"Camera Roll", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.picker.navigationBar.translucent = false
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (alert) -> Void in
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

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let cropController = ImageCropViewController(image: chosenImage)
        cropController.delegate = self
        navigationController?.pushViewController(cropController, animated: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ImageCropViewControllerSuccess(controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        imageSelected = croppedImage
        podImageView.image = croppedImage
        podImageView.contentMode = .ScaleAspectFill

        navigationController?.popViewControllerAnimated(true)
    }
    
    func ImageCropViewControllerDidCancel(controller: UIViewController!) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: CollectionView Datasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCollectionViewCell", forIndexPath: indexPath) as? UserImageCollectionViewCell
        if cell == nil {
            cell = UserImageCollectionViewCell()
        }
        cell?.configureAsAddUser()
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectMembersVC = SelectPODMembersViewController()
        navigationController?.pushViewController(selectMembersVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80 , height: 110)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK UItextViewDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.length > 0 && string == "" {
            return true
        } else if textField.text!.characters.count >= maxNameCharacters {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        leftCharactersLabel.text = String(format: "%li / %li", arguments: [textField.text!.characters.count, maxNameCharacters])
    }
    
    // MARK: - Actions
    
    func saveSettingsPressed(sender: AnyObject) {
        print("Save Pressed")
        
        // create the POD
        var newWidth: CGFloat
        if podNameTextField.text != "" && podDescriptionTextView.text != "" {
            if imageSelected != nil {
                if imageSelected!.size.width < 414 {
                    newWidth = imageSelected!.size.width
                } else {
                    newWidth = 414
                }
                let resizedImage = Utils.resizeImage(imageSelected!, newWidth: newWidth)
                // crate the pod
                let podToSave = POD(name: podNameTextField.text, description: podDescriptionTextView.text, imageURL: nil, isPrivate: (switchIsPrivate.on ? 1 : 0), owner: nil, users: [], postsCount: nil, usersCount: nil, imageData: resizedImage)
                SVProgressHUD.showWithStatus("Posting")
                networkController.createPOD(podToSave, completionHandler: { (pod, error) -> () in
                    if error == nil {
                        
                        if pod?.id != nil {
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
                alert = UIAlertController(title: "Error", message: "Please, select an image", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "Please, complete all the fields", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
