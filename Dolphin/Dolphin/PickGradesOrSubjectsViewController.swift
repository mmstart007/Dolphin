//
//  PickGradesOrSubjectsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
import BEMCheckBox

protocol PickerGradesOrSubjectsDelegate {
    func gradesDidSelected(grades: [Grade])
    func subjectsDidSelected(subjects: [Subject])
}

class PickGradesOrSubjectsViewController: DolphinViewController, UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var tableViewGradesOrSubjects: UITableView!
    var checkBoxAll: BEMCheckBox!
    
    var delegate: PickerGradesOrSubjectsDelegate?
    var areSubjects: Bool = false
    var fromSettings: Bool = false
    
    var grades: [Grade] = []
    var gradesSelected: [Grade] = []
    
    var subjects: [Subject] = []
    var subjectsSelected: [Subject] = []
    
    convenience init() {
        self.init(nibName: "PickGradesOrSubjectsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = areSubjects ? "Select subjects" : "Select grades"
        setRightButtonItemWithText("Done", target: self, action: Selector("doneTouchUpInside:"))
        setBackButton()        
        tableViewGradesOrSubjects.delegate = self
        tableViewGradesOrSubjects.dataSource = self
        tableViewGradesOrSubjects.tableFooterView = UIView(frame: CGRectZero)
        registerCells()
        
        self.loadData()
    }

    override func setBackButton() {
        
        let spacer = UIBarButtonItem()
        spacer.width = -10;
        
        checkBoxAll = BEMCheckBox(frame: CGRectMake(0, 0, 30, 30))
        checkBoxAll.tintColor = UIColor.whiteColor()
        checkBoxAll.animationDuration = 0
        checkBoxAll.onAnimationType = .Bounce
        checkBoxAll.offAnimationType = .Bounce
        checkBoxAll.delegate = self
        let leftButton = UIBarButtonItem(customView: checkBoxAll)
        self.navigationItem.leftBarButtonItems = [spacer, leftButton];
    }
    
    func checkAllButton() {
        if(areSubjects) {
            
            if self.subjects.count == self.subjectsSelected.count {
                checkBoxAll.on = true
            } else {
                checkBoxAll.on = false
            }
        } else {
            
            if self.grades.count == self.gradesSelected.count {
                checkBoxAll.on = true
            } else {
                checkBoxAll.on = false
            }
        }
    }
    
    func didTapCheckBox(checkBox: BEMCheckBox) {
        if(checkBoxAll.on) {
            if areSubjects {
                subjectsSelected.removeAll()
                for item in self.subjects {
                    subjectsSelected.append(item)
                }
            } else {
                gradesSelected.removeAll()
                for item in self.grades {
                    gradesSelected.append(item)
                }
                
            }
            
        } else {
            subjectsSelected.removeAll()
            gradesSelected.removeAll()
        }
        
        tableViewGradesOrSubjects.reloadData()
    }
    
    func loadData()
    {
        SVProgressHUD.showWithStatus("Loading...")
        if(areSubjects) {
            
            //Load Subjects
            networkController.getSubjects { (arrSubjects, error) -> () in
                SVProgressHUD.dismiss()
                
                self.subjects.removeAll()
                if(arrSubjects != nil) {
                    for item in arrSubjects! {
                        self.subjects.append(item)
                    }
                }
                
                self.checkAllButton()
                self.tableViewGradesOrSubjects.reloadData()
            }
        }
        else {
            
            //Load Grades
            networkController.getGrades { (arrGrades, error) -> () in
                SVProgressHUD.dismiss()
                
                self.grades.removeAll()
                if(arrGrades != nil) {
                    for item in arrGrades! {
                        self.grades.append(item)
                    }
                }
                
                self.checkAllButton()
                self.tableViewGradesOrSubjects.reloadData()
            }
        }
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
            let s = subjects[indexPath.row]
            cell?.configureWithGradeOrSubjectName(s.name!, checked: self.isSelectedSubject(s))
        } else {
            let g = grades[indexPath.row]
            cell?.configureWithGradeOrSubjectName(g.name!, checked: self.isSelectedGrade(g))
        }
        
        cell?.selectionStyle = .None
        return cell!
    }
    
    func isSelectedSubject(s: Subject) ->Bool {
        for item in subjectsSelected {
            if item.id == s.id {
                return true
            }
        }
        
        return false
    }

    func isSelectedGrade(g: Grade) ->Bool {
        for item in gradesSelected {
            if item.id == g.id {
                return true
            }
        }
        
        return false
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
        
        if fromSettings {
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewGradesOrSubjects.registerNib(UINib(nibName: "SubjectOrGradeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SubjectOrGradeTableViewCell")
        
    }
}
