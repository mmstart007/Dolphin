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
    
    @IBOutlet weak var gradeView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavBarStyle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // put bar back to default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func finishProfileButtonTouchUpInside(_ sender: AnyObject) {
        // TODO: Update the user with the collection of grades and subjects
        
        var grade_ids: [String] = []
        for item in selectedGrades {
            grade_ids.append(String(format: "%d", item.id!))
        }

        var subject_ids: [String] = []
        for item in selectedSubjects {
            subject_ids.append(String(format: "%d", item.id!))
        }
        
        SVProgressHUD.show(withStatus: "Saving...")
        networkController.updateGradesAndSubjects(grade_ids, subjects: subject_ids) { (user, error) -> () in
            
            SVProgressHUD.dismiss()
            
            if((error) != nil) {
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
            else {
                
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController((UIApplication.shared.delegate as! AppDelegate).homeViewController, animated: true)
            }
        }
    }
    
    @IBAction func gradeButtonTouchUpInside(_ sender: AnyObject) {
        
        let pickGradesVC = PickGradesOrSubjectsViewController()
        pickGradesVC.delegate = self
        pickGradesVC.areSubjects = false
        pickGradesVC.gradesSelected = selectedGrades
        pickGradesVC.subjectsSelected = selectedSubjects
        let pickGradesNavController = UINavigationController(rootViewController: pickGradesVC)
        present(pickGradesNavController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func subjectButtonTouchUpInside(_ sender: AnyObject) {
        
        let pickSubjectsVC = PickGradesOrSubjectsViewController()
        pickSubjectsVC.delegate = self
        pickSubjectsVC.areSubjects = true
        pickSubjectsVC.gradesSelected = selectedGrades
        pickSubjectsVC.subjectsSelected = selectedSubjects
        let pickSubjectsNavController = UINavigationController(rootViewController: pickSubjectsVC)
        present(pickSubjectsNavController, animated: true, completion: nil)
        
    }
    
    // MARK: - PickerGradesOrSubjects delegate
    
    func gradesDidSelected(_ grades: [Grade]) {
        selectedGrades = grades

        var names: [String] = []
        for item in selectedGrades {
            names.append(item.name!)
        }
        
        let gradesString = names.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        
        let title = selectedGrades.count == 0 ? "grades" : gradesString
        gradeLabel.text = title
    }
    
    func subjectsDidSelected(_ subjects: [Subject]) {
        selectedSubjects = subjects
        
        var names: [String] = []
        for item in selectedSubjects {
            names.append(item.name!)
        }
        
        let subjectsString = names.reduce("") { (accum, actual) -> String in
            accum + ((accum == "") ? "" : ", ") + actual
        }
        
        let title = selectedGrades.count == 0 ? "subjects" : subjectsString
        subjectLabel.text = title
    }
    
    // MARK: - Auxilary methods
    
    func setAppearance() {
        
        gradeView.layer.cornerRadius         = gradeView.frame.height/2.0
        gradeView.layer.borderWidth          = 1
        gradeView.layer.borderColor          = UIColor.white.cgColor
    
        subjectsView.layer.cornerRadius       = subjectsView.frame.height/2.0
        subjectsView.layer.borderWidth        = 1
        subjectsView.layer.borderColor        = UIColor.white.cgColor

        finishProfileButton.layer.cornerRadius = finishProfileButton.frame.height/2.0
    }
    
    func setNavBarStyle() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    

}
