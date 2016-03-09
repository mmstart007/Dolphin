//
//  CreateProfileViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/7/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CreateProfileViewController: DolphinViewController {
    
    @IBOutlet weak var gradeButton: UIButton!
    @IBOutlet weak var subjectButton: UIButton!
    @IBOutlet weak var finishProfileButton: UIButton!
    
    
    convenience init() {
        self.init(nibName: "CreateProfileViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
        setBackButton()
        setNavBarStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setAppearance()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // put bar back to default
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func finishProfileButtonTouchUpInside(sender: AnyObject) {
        navigationController?.pushViewController((UIApplication.sharedApplication().delegate as! AppDelegate).homeViewController, animated: true)
        
    }
    
    @IBAction func gradeButtonTouchUpInside(sender: AnyObject) {
        
        let grades = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
        
        ActionSheetStringPicker.showPickerWithTitle("Select a Grade", rows: grades, initialSelection: 1, doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            self.gradeButton.setTitle(String(index), forState: .Normal)
            
            return
            
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func subjectButtonTouchUpInside(sender: AnyObject) {
        
        let subjects = ["Mathematics", "Biology", "Chemistry", "Physics", "Music", "History", "Geography"];
        
        ActionSheetStringPicker.showPickerWithTitle("Select a Subject", rows: subjects, initialSelection: 1, doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            self.subjectButton.setTitle(String(index), forState: .Normal)
            
            return
            
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    
    
    // MARK: - Auxilary methods
    
    func setAppearance() {
        
        gradeButton.layer.cornerRadius         = 20
        gradeButton.layer.borderWidth          = 1
        gradeButton.layer.borderColor          = UIColor.whiteColor().CGColor
        let downImage = UIImage(named: "DownImage")
        gradeButton.setImage(downImage, forState: .Normal)
        gradeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: gradeButton.frame.size.width - (downImage!.size.width + 15), bottom: 0, right: 10)
        
    
        subjectButton.layer.cornerRadius       = 20
        subjectButton.layer.borderWidth        = 1
        subjectButton.layer.borderColor        = UIColor.whiteColor().CGColor
        subjectButton.setImage(downImage, forState: .Normal)
        subjectButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: subjectButton.frame.size.width - (downImage!.size.width + 15), bottom: 0, right: 10)
        finishProfileButton.layer.cornerRadius = 20
        
    
    }
    
    func setNavBarStyle() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.view.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    

}
