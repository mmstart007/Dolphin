//
//  PickGradesOrSubjectsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol PickerGradesOrSubjectsDelegate {
    func gradesDidSelected(grades: [String])
    func subjectsDidSelected(subjects: [String])
}

class PickGradesOrSubjectsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource {

//    let grades = ["Pre-K", "K", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th"];
//    let subjects = ["Mathematics", "Biology", "Chemistry", "Physics", "History", "Geography"
//        , "Physical", "Education", "Health", "Music", "Art", "Foreign Language", "Social Studies", "English Language Arts"
//        , "Counseling", "STEM", "Science"];
    
    @IBOutlet weak var tableViewGradesOrSubjects: UITableView!
    
    var delegate: PickerGradesOrSubjectsDelegate?
    var areSubjects: Bool          = false
    var subjectsSelected: [String] = []
    var gradesSelected: [String]   = []
    var grades: [Grade]            = []
    var subjects: [Subject]        = []
    var user = NetworkController.sharedInstance.currentUser
    
    convenience init() {
        self.init(nibName: "PickGradesOrSubjectsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = areSubjects ? "Select subjects" : "Select grades"
        setRightButtonItemWithText("Done", target: self, action: Selector("doneTouchUpInside:"))
        
        if user != nil {
            setLeftButtonItemWithText("Close", target: self, action: #selector(closeButtonTouchUpInside))
        }
        
        tableViewGradesOrSubjects.delegate = self
        tableViewGradesOrSubjects.dataSource = self
        tableViewGradesOrSubjects.tableFooterView = UIView(frame: CGRectZero)
        registerCells()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if areSubjects {
            return subjects.count
        } else {
            return grades.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SubjectOrGradeTableViewCell? = tableViewGradesOrSubjects.dequeueReusableCellWithIdentifier("SubjectOrGradeTableViewCell") as? SubjectOrGradeTableViewCell
        if cell == nil {
            cell = SubjectOrGradeTableViewCell()
        }
        if areSubjects {
            cell?.configureWithGradeOrSubjectName(subjects[indexPath.row].name!, checked: subjectsSelected.contains(subjects[indexPath.row].name!))
        } else {
            cell?.configureWithGradeOrSubjectName(grades[indexPath.row].name!, checked: gradesSelected.contains(grades[indexPath.row].name!))
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Tableview delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if areSubjects {
            if subjectsSelected.contains(subjects[indexPath.row].name!) {
                let indexToRemove = subjectsSelected.indexOf(subjects[indexPath.row].name!)
                subjectsSelected.removeAtIndex(indexToRemove!)
            } else {
                subjectsSelected.append(subjects[indexPath.row].name!)
            }
        } else {
            if gradesSelected.contains(grades[indexPath.row].name!) {
                let indexToRemove = gradesSelected.indexOf(grades[indexPath.row].name!)
                gradesSelected.removeAtIndex(indexToRemove!)
            } else {
                gradesSelected.append(grades[indexPath.row].name!)
            }
        }
        tableViewGradesOrSubjects.reloadData()
    }
    
    // MARK: - Actions
    
    func doneTouchUpInside(sender: AnyObject) {
        if user == nil {
            if areSubjects {
                delegate?.subjectsDidSelected(subjectsSelected)
            } else {
                delegate?.gradesDidSelected(gradesSelected)
            }
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            SVProgressHUD.showWithStatus("Saving")
            NetworkController.sharedInstance.updateUser(nil, deviceId: nil, firstName: nil, lastName: nil, avatarImage: nil, email: nil, password: nil, location: nil, isPrivate: nil, subjects: subjectsSelected, grades: gradesSelected, completionHandler: { (user, error) in
                if error == nil && user != nil {
                    NetworkController.sharedInstance.currentUser = user
                    if self.areSubjects {
                        self.delegate?.subjectsDidSelected(self.subjectsSelected)
                    } else {
                        self.delegate?.gradesDidSelected(self.gradesSelected)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
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
    }
    
    func closeButtonTouchUpInside(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewGradesOrSubjects.registerNib(UINib(nibName: "SubjectOrGradeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SubjectOrGradeTableViewCell")
    }
    
    


}
