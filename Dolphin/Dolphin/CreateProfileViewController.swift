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
    
    var selectedGrades: [Grade] = []
    var selectedSubjects: [Subject] = []
    
    convenience init() {
        self.init(nibName: "CreateProfileViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
        navigationItem.hidesBackButton = true
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
        // TODO: Update the user with the collection of grades and subjects
        
        var grade_ids: [String] = []
        for item in selectedGrades {
            grade_ids.append(String(format: "%d", item.id!))
        }

        var subject_ids: [String] = []
        for item in selectedSubjects {
            subject_ids.append(String(format: "%d", item.id!))
        }
        
        SVProgressHUD.showWithStatus("Saving...")
        networkController.updateGradesAndSubjects(grade_ids, subjects: subject_ids) { (user, error) -> () in
            
            SVProgressHUD.dismiss()
            
            if((error) != nil) {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(Globals.jsonToNSData((user?.toJson())!), forKey: "current_user")
                defaults.synchronize()
            }
            else {
                self.navigationController?.pushViewController((UIApplication.sharedApplication().delegate as! AppDelegate).homeViewController, animated: true)
            }
        }
    }
    
    @IBAction func gradeButtonTouchUpInside(sender: AnyObject) {
        
        let pickGradesVC = PickGradesOrSubjectsViewController()
        pickGradesVC.delegate = self
        pickGradesVC.areSubjects = false
        pickGradesVC.gradesSelected = selectedGrades
        pickGradesVC.subjectsSelected = selectedSubjects
        let pickGradesNavController = UINavigationController(rootViewController: pickGradesVC)
        presentViewController(pickGradesNavController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func subjectButtonTouchUpInside(sender: AnyObject) {
        
        let pickSubjectsVC = PickGradesOrSubjectsViewController()
        pickSubjectsVC.delegate = self
        pickSubjectsVC.areSubjects = true
        pickSubjectsVC.gradesSelected = selectedGrades
        pickSubjectsVC.subjectsSelected = selectedSubjects
        let pickSubjectsNavController = UINavigationController(rootViewController: pickSubjectsVC)
        presentViewController(pickSubjectsNavController, animated: true, completion: nil)
        
    }
    
    // MARK: - PickerGradesOrSubjects delegate
    
    func gradesDidSelected(grades: [Grade]) {
        selectedGrades = grades

        var names: [String] = []
        for item in selectedGrades {
            names.append(item.name!)
        }
        
        let gradesString = names.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        
        let title = selectedGrades.count == 0 ? "grades" : gradesString
        gradeButton.setTitle(title, forState: .Normal)
        gradeButton.setTitle(title, forState: .Selected)
    }
    
    func subjectsDidSelected(subjects: [Subject]) {
        selectedSubjects = subjects
        
        var names: [String] = []
        for item in selectedSubjects {
            names.append(item.name!)
        }
        
        let subjectsString = names.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        
        let title = selectedGrades.count == 0 ? "subjects" : subjectsString
        subjectButton.setTitle(title, forState: .Normal)
        subjectButton.setTitle(title, forState: .Selected)
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
