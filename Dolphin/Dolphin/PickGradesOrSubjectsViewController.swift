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
    func gradesDidSelected(_ grades: [Grade])
    func subjectsDidSelected(_ subjects: [Subject])
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
        
        checkBoxAll = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkBoxAll.tintColor = UIColor.white
        checkBoxAll.animationDuration = 0
        checkBoxAll.onAnimationType = .bounce
        checkBoxAll.offAnimationType = .bounce
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
    
    func didTap(_ checkBox: BEMCheckBox) {
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
        SVProgressHUD.show(withStatus: "Loading...")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if areSubjects {
            return subjects.count
        } else {
            return grades.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SubjectOrGradeTableViewCell? = tableViewGradesOrSubjects.dequeueReusableCell(withIdentifier: "SubjectOrGradeTableViewCell") as? SubjectOrGradeTableViewCell
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
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: nil, message: "Are you sure to remove?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
                
            })
            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isSelectedSubject(_ s: Subject) ->Bool {
        for item in subjectsSelected {
            if item.id == s.id {
                return true
            }
        }
        
        return false
    }

    func isSelectedGrade(_ g: Grade) ->Bool {
        for item in gradesSelected {
            if item.id == g.id {
                return true
            }
        }
        
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func deselectGrade(_ g: Grade) {
        var index = 0
        for item in gradesSelected {
            if item.id == g.id {
                gradesSelected.remove(at: index)
                return
            }
            index += 1
        }
    }
    
    func deselectSubject(_ s: Subject) {
        var index = 0
        for item in subjectsSelected {
            if item.id == s.id {
                subjectsSelected.remove(at: index)
                return
            }
            index += 1
        }
    }
    
    // MARK: - Actions
    
    func doneTouchUpInside(_ sender: AnyObject) {
        if areSubjects {
            delegate?.subjectsDidSelected(subjectsSelected)
        } else {
            delegate?.gradesDidSelected(gradesSelected)
        }
        
        if fromSettings {
            let _ = navigationController?.popViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }

    }
    
    // MARK: - Auxiliary methods
    func registerCells() {
        tableViewGradesOrSubjects.register(UINib(nibName: "SubjectOrGradeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SubjectOrGradeTableViewCell")
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
        let newPrompt = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        newPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        newPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            let name = inputTextField?.text
            print(name!)

        }))
        newPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            inputTextField = textField
        })
        
        present(newPrompt, animated: true, completion: nil)
    }
}
