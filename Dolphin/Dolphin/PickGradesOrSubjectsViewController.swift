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
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerTitle: UILabel!
    
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
        setRightButtonItemWithText("Done", target: self, action: #selector(PickGradesOrSubjectsViewController.doneTouchUpInside(_:)))
        setBackButton()        
        tableViewGradesOrSubjects.delegate = self
        tableViewGradesOrSubjects.dataSource = self
//        tableViewGradesOrSubjects.tableFooterView = footerView
//        if areSubjects == true {
//            footerTitle.text = "Add Subject"
//        }
//        else {
//            footerTitle.text = "Add Grade"            
//        }
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let alertController = UIAlertController(title: nil, message: "Are you sure to remove?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { action -> Void in
                
            })
            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
            if isSelectedSubject(subjects[indexPath.row]) {
                deselectSubject(subjects[indexPath.row])
            } else {
                subjectsSelected.append(subjects[indexPath.row])
            }
        } else {
            if isSelectedGrade(grades[indexPath.row]) {
                deselectGrade(grades[indexPath.row])
            } else {
                gradesSelected.append(grades[indexPath.row])
            }
        }
        
        tableViewGradesOrSubjects.reloadData()
    }
    
    func deselectGrade(g: Grade) {
        var index = 0
        for item in gradesSelected {
            if item.id == g.id {
                gradesSelected.removeAtIndex(index)
                return
            }
            index += 1
        }
    }
    
    func deselectSubject(s: Subject) {
        var index = 0
        for item in subjectsSelected {
            if item.id == s.id {
                subjectsSelected.removeAtIndex(index)
                return
            }
            index += 1
        }
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
    
    // MAKR: - Add Grade / Subject
    
    @IBAction func tapFooterView() {
        var message = ""
        if areSubjects {
            message = "Please type new subject name."
        } else {
            message = "Please type new grade name."
        }
        
        var inputTextField: UITextField?
        let newPrompt = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        newPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        newPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            let name = inputTextField?.text
            print(name)

        }))
        newPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
            inputTextField = textField
        })
        
        presentViewController(newPrompt, animated: true, completion: nil)
    }
}
