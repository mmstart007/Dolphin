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


class CreatePodViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, SelectPODMembersDelegate {
    
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
    var selectedCropRect: CGRect! = CGRectZero
    var imageOriginalSelected: UIImage?
    var podUpdate: POD?
    var selectedMembers: [User] = []
    
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
        
        podImageView.userInteractionEnabled = true
        let tapPodImageView = UITapGestureRecognizer(target: self, action: "didTapPodImageView")
        podImageView.addGestureRecognizer(tapPodImageView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setRightButtonItemWithText("Save", target: self, action: Selector("saveSettingsPressed:"))
        title = self.podUpdate == nil ? "Create a POD":"Edit a POD"
        
        membersCollectionView.registerNib(UINib(nibName: "UserImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "UserImageCollectionViewCell")
        membersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        membersCollectionView.dataSource = self
        membersCollectionView.delegate   = self
        
        if(self.podUpdate != nil)
        {
            podNameTextField.text = self.podUpdate?.name
            podDescriptionTextView.text = self.podUpdate?.descriptionText
            switchIsPrivate.setOn(self.podUpdate?.isPrivate == 1, animated: true)
            //podImageView.sd_setImageWithURL(NSURL(string: (self.podUpdate?.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
            if(self.podUpdate?.users != nil)
            {
                membersDidSelected((self.podUpdate?.users)!)
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: NSURL(string: self.podUpdate!.imageURL!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    if(data != nil)
                    {
                        self.podImageView.image = UIImage(data: data!)
                    }
                    else{
                        self.podImageView.sd_setImageWithURL(NSURL(string: (self.podUpdate!.imageURL)!), placeholderImage: UIImage(named: "PostImagePlaceholder"))
                    }
                });
            }

        }
        
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
        imageOriginalSelected = info[UIImagePickerControllerOriginalImage] as! UIImage
        let cropController = ImageCropViewController(image: imageOriginalSelected, cropRect: CGRectZero)
        cropController.delegate = self
        navigationController?.pushViewController(cropController, animated: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func didTapPodImageView() {
        if self.imageOriginalSelected != nil {
            let cropController = ImageCropViewController(image: imageOriginalSelected, cropRect: selectedCropRect)
            cropController.delegate = self
            navigationController?.pushViewController(cropController, animated: true)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ImageCropViewControllerSuccess(controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!, cropRect: CGRect) {
        selectedCropRect = cropRect
        imageSelected = croppedImage
        podImageView.image = croppedImage
        //        podImageView.contentMode = .ScaleAspectFill
        
        print("width = " + "\(imageSelected?.size.width)")
        print("height = " + "\(imageSelected?.size.height)")
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
        return selectedMembers.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCollectionViewCell", forIndexPath: indexPath) as? UserImageCollectionViewCell
        if cell == nil {
            cell = UserImageCollectionViewCell()
        }
        if indexPath.row == 0 {
            cell?.configureAsAddUser()
        } else {
            cell?.configureWithUser(selectedMembers[indexPath.row - 1])
        }
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let selectMembersVC = SelectPODMembersViewController()
            selectMembersVC.delegate = self
            selectMembersVC.selectedMembers = selectedMembers
            navigationController?.pushViewController(selectMembersVC, animated: true)
        } else {
            let user = selectedMembers[indexPath.row - 1]
            self.deleteUser(user)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80 , height: 110)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func deleteUser(user: User) {
        var index = 0
        for u in selectedMembers {
            if u.id == user.id {
                selectedMembers.removeAtIndex(index)
                break;
            }
            
            index = index + 1
        }
        membersCollectionView.reloadData()
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
            if (imageSelected != nil || (self.podUpdate != nil && self.podUpdate?.imageURL != nil)){
//                if imageSelected!.size.width < 414 {
//                    newWidth = imageSelected!.size.width
//                } else {
//                    newWidth = 414
//                }
//                let resizedImage = Utils.resizeImage(imageSelected!, newWidth: newWidth)
                
                // crate the pod
                if(self.podUpdate == nil)
                {
                    let podToSave = POD(name: podNameTextField.text, description: podDescriptionTextView.text, imageURL: nil, isPrivate: (switchIsPrivate.on ? 1 : 0), owner: nil, users: selectedMembers, postsCount: nil, usersCount: nil, imageData: imageSelected, image_width: Int(imageSelected!.size.width), image_height: Int(imageSelected!.size.height), total_unread: 0)
                
                    SVProgressHUD.showWithStatus("Creating POD")
                    networkController.createPOD(podToSave, completionHandler: { (pod, error) -> () in
                        if error == nil {
                        
                        if pod?.id != nil {
                            // everything worked ok
                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPod, object: nil, userInfo: ["pod":pod!])
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
                else{
                    var retDic = [String: AnyObject]()
                    
                    if let podId = podUpdate!.id {
                        retDic["id"] = podId
                    }
                    
                    let podToSave = PODRequest(name: podNameTextField.text, description: podDescriptionTextView.text, isPrivate: (switchIsPrivate.on ? 1 : 0), users: selectedMembers, imageData: nil, image_width: podUpdate!.image_width, image_height: podUpdate!.image_height)
                    if let podId = podUpdate!.id {
                        podToSave.id = podId
                    }
                    if(imageSelected != nil)
                    {
                        podToSave.imageData = imageSelected
                        podToSave.image_width = Int(imageSelected!.size.width)
                        podToSave.image_height = Int(imageSelected!.size.height)
                    }
                    
                    SVProgressHUD.showWithStatus("Updating POD")
                    networkController.updateInfoPOD(podToSave, completionHandler: { (pod, error) -> () in
                        if error == nil {
                            
                            if pod?.id != nil {
                                // everything worked ok
                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPod, object: nil, userInfo: ["pod":pod!])
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
                    
                    /*retDic["name"] = "This is pod"//podNameTextField.text
                    retDic["descriptionText"] = "Pod update description"//podDescriptionTextView.text
                    //retDic["isPrivate"] = switchIsPrivate.on ? 1 : 0
                    if(imageSelected != nil)
                    {
                        retDic["imageData"] = imageSelected
                        retDic["image_width"] = Int(imageSelected!.size.width)
                        retDic["image_height"] = Int(imageSelected!.size.height)
                    }
                    
                    
                    SVProgressHUD.show()
                    networkController.updatePod(retDic) { (updatedPod, error) in
                        SVProgressHUD.dismiss()
                    }*/
                }
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
    
    // MARK: - SelectPODMembersDelegate
    
    func membersDidSelected(members: [User]) {
        selectedMembers = members
        membersCollectionView.reloadData()
    }
    
}
