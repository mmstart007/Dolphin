//
//  CreatePodViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

class CreatePodViewController : DolphinViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var podImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var leftCharactersLabel: UILabel!
    @IBOutlet weak var podNameTextField: UITextField!
    let picker = UIImagePickerController()
    let maxNameCharacters = 20
    
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        title = "Create a POD"
        
        membersCollectionView.registerNib(UINib(nibName: "UserImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "UserImageCollectionViewCell")
        membersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        membersCollectionView.dataSource = self
        membersCollectionView.delegate   = self
        
        podNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        leftCharactersLabel.text = String(format: "%li / %li", arguments: [(podNameTextField!.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!, maxNameCharacters])
        let tapViewGesture = UITapGestureRecognizer(target: self, action: "resignResponder")
        self.view.addGestureRecognizer(tapViewGesture)
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
    
}
