//
//  CreateTextPostViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder

class CreateTextPostViewController : DolphinViewController {
    
    @IBOutlet weak var postToFieldView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var visibilityIconImageView: UIImageView!
    @IBOutlet weak var visibilityLabel: UILabel!
    
    convenience init() {
        self.init(nibName: "CreateTextPostViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissButton()
        title = "Write"
        setRightSystemButtonItem(.Done, target: self, action: nil)
        let tapVisibilityViewGesture = UITapGestureRecognizer(target: self, action: "goToPrivacySettings")
        postToFieldView.addGestureRecognizer(tapVisibilityViewGesture)
        
        setupFields()
    }
    
    func setupFields() {
        postTextView.placeholderColor = UIColor.lightGrayColor()
        postTextView.placeholder = "Write your moment..."
    }
    
    // MARK: Privacy Settings
    
    func goToPrivacySettings() {
        let privacySettingsVC = NewPostPrivacySettingsViewController()
        let privacySettingsNavController = UINavigationController(rootViewController: privacySettingsVC)
        presentViewController(privacySettingsNavController, animated: true, completion: nil)
    }
    
}