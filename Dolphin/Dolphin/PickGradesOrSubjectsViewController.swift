//
//  PickGradesOrSubjectsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

protocol PickerGradesOrSubjectsDelegate {
    func gradesDidSelected(grades: [String])
    func subjectsDidSelected(subjects: [String])
}

class PickGradesOrSubjectsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource {

    let grades = ["Pre-K", "K", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th"];
    let subjects = ["Mathematics", "Biology", "Chemistry", "Physics", "History", "Geography"
        , "Physical", "Education", "Health", "Music", "Art", "Foreign Language", "Social Studies", "English Language Arts"
        , "Counseling", "STEM", "Science"];
    
    @IBOutlet weak var tableViewGradesOrSubjects: UITableView!
    
    var delegate: PickerGradesOrSubjectsDelegate?
    var areSubjects: Bool = false
    var subjectsSelected: [String] = []
    var gradesSelected: [String] = []
    
    convenience init() {
        self.init(nibName: "PickGradesOrSubjectsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = areSubjects ? "Select subjects" : "Select grades"
        setRightButtonItemWithText("Done", target: self, action: Selector("doneTouchUpInside:"))
        
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
            cell?.configureWithGradeOrSubjectName(subjects[indexPath.row], checked: subjectsSelected.contains(subjects[indexPath.row]))
        } else {
            cell?.configureWithGradeOrSubjectName(grades[indexPath.row], checked: gradesSelected.contains(grades[indexPath.row]))
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
            if subjectsSelected.contains(subjects[indexPath.row]) {
                let indexToRemove = subjectsSelected.indexOf(subjects[indexPath.row])
                subjectsSelected.removeAtIndex(indexToRemove!)
            } else {
                subjectsSelected.append(subjects[indexPath.row])
            }
        } else {
            if gradesSelected.contains(grades[indexPath.row]) {
                let indexToRemove = gradesSelected.indexOf(grades[indexPath.row])
                gradesSelected.removeAtIndex(indexToRemove!)
            } else {
                gradesSelected.append(grades[indexPath.row])
            }
        }
        tableViewGradesOrSubjects.reloadData()
    }
    
    // MARK: - Actions
    
    func doneTouchUpInside(sender: AnyObject) {
        if areSubjects {
            delegate?.subjectsDidSelected(subjectsSelected)
        } else {
            delegate?.gradesDidSelected(gradesSelected)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewGradesOrSubjects.registerNib(UINib(nibName: "SubjectOrGradeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SubjectOrGradeTableViewCell")
        
    }
    
    


}
