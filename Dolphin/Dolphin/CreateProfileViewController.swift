//
//  CreateProfileViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/7/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD

class CreateProfileViewController: DolphinViewController, PickerGradesOrSubjectsDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var gradeButton: UIButton!
    @IBOutlet weak var subjectButton: UIButton!
    @IBOutlet weak var finishProfileButton: UIButton!

    var availableGrades: [Grade]     = []
    var availableSubjects: [Subject] = []
    var selectedGrades: [String]     = []
    var selectedSubjects: [String]   = []
    
    convenience init() {
        self.init(nibName: "CreateProfileViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
        navigationItem.hidesBackButton = true
        loadGradesAndSubjects()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setAppearance()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavBarStyle()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
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
        // call the api function to update the user info
        SVProgressHUD.showWithStatus("Saving")
        networkController.updateUser(nil, deviceId: nil, firstName: nil, lastName: nil, avatarImage: nil, email: nil, password: nil, location: nil, isPrivate: nil, subjects: selectedSubjects, grades: selectedGrades) { (user, error) -> () in
            if error == nil {
                // update the user modified
                self.networkController.currentUser = user
                
                SVProgressHUD.dismiss()
                self.navigationController?.pushViewController((UIApplication.sharedApplication().delegate as! AppDelegate).homeViewController, animated: true)
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
        
        
    }
    
    @IBAction func gradeButtonTouchUpInside(sender: AnyObject) {
        
        let pickGradesVC              = PickGradesOrSubjectsViewController()
        pickGradesVC.delegate         = self
        pickGradesVC.areSubjects      = false
        pickGradesVC.grades           = availableGrades
        pickGradesVC.gradesSelected   = selectedGrades
        pickGradesVC.subjectsSelected = selectedSubjects
        let pickGradesNavController   = UINavigationController(rootViewController: pickGradesVC)
        presentViewController(pickGradesNavController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func subjectButtonTouchUpInside(sender: AnyObject) {
        
        let pickSubjectsVC              = PickGradesOrSubjectsViewController()
        pickSubjectsVC.delegate         = self
        pickSubjectsVC.areSubjects      = true
        pickSubjectsVC.subjects         = availableSubjects
        pickSubjectsVC.gradesSelected   = selectedGrades
        pickSubjectsVC.subjectsSelected = selectedSubjects
        let pickSubjectsNavController   = UINavigationController(rootViewController: pickSubjectsVC)
        presentViewController(pickSubjectsNavController, animated: true, completion: nil)
        
    }
    
    // MARK: - PickerGradesOrSubjects delegate
    
    func gradesDidSelected(grades: [String]) {
        selectedGrades = grades
        let gradesString = selectedGrades.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        gradeButton.titleLabel?.text = selectedGrades.count == 0 ? "grades" : gradesString
        print(grades)
    }
    
    func subjectsDidSelected(subjects: [String]) {
        selectedSubjects = subjects
        let subjectsString = selectedSubjects.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        subjectButton.titleLabel?.text = selectedSubjects.count == 0 ? "subjects" : subjectsString
        print(subjects)
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
    
    func loadGradesAndSubjects() {
        SVProgressHUD.showWithStatus("Loading")
        networkController.getGrades { (grades, error) -> () in
            if error == nil {
                self.availableGrades = grades!
                
                self.networkController.getSubjects { (subjects, error) -> () in
                    if error == nil {
                        
                        self.availableSubjects = subjects!
                        SVProgressHUD.dismiss()
                        
                    } else {
                        let errors: [String]? = error!["errors"] as? [String]
                        let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }
                
                
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
        
        

    }

}
