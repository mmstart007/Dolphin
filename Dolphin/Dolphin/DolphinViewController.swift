//
//  DolphinViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import BSKeyboardControls

class DolphinViewController : DolphinCustomFontViewController, BSKeyboardControlsDelegate {
    
    var parentScrollView: UIScrollView?
    var textFieldsForKeyboardControls: [UITextField] = []
    var keyboardControls: BSKeyboardControls = BSKeyboardControls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardControls.delegate = self
        //        let tapGesture = UITapGestureRecognizer(target: self, action: "resignResponder")
        //        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    
    func setBackButton() {
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(goBackButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setDismissButton() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(dismissButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func goBackButtonPressed(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismissButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setRightSystemButtonItem(_ systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setRightButtonItemWithText(_ text: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        rightButton.tintColor = UIColor.white
        rightButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Constants.Fonts.Raleway_Regular, size: 14)!], for: UIControlState())
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setLeftButtonItemWithText(_ text: String, target: AnyObject?, action: Selector) {
        let leftButton = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        leftButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func addRightButtonItemWithImage(_ imageName: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: target, action: action)
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItems?.append(rightButton)
    }
    
    func resignResponder() {
        if let firstResponder = view.findViewThatIsFirstResponder() {
            firstResponder.resignFirstResponder()
        }
    }
    
    // MARK: Handle Keyboard showing
    
    func keyboardWillShow(_ notification: Foundation.Notification) {
        
        if let activeView = self.view.findViewThatIsFirstResponder() {
            if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                parentScrollView?.contentInset = contentInsets
                parentScrollView?.scrollIndicatorInsets = contentInsets
                var aRect = self.view.frame
                aRect.size.height -= keyboardSize.height;
                let activeViewAbsoluteFrame = activeView.convert(activeView.frame, to: nil)
//                let distance = (UIScreen.mainScreen().bounds.height - keyboardSize.height) - (activeViewAbsoluteFrame.origin.y + activeViewAbsoluteFrame.size.height)
                if !aRect.contains(activeViewAbsoluteFrame.origin) {
                    parentScrollView?.scrollRectToVisible(activeViewAbsoluteFrame, animated: true)
                }
            }
        }
    }
    
    func keyboardWillHide(_ notification: Foundation.Notification) {
        
        let contentInsets = UIEdgeInsets.zero
        parentScrollView?.contentInset = contentInsets
        parentScrollView?.scrollIndicatorInsets = contentInsets
        
    }
    
    // MARK: - Keyboard Controls
    
    func keyboardControls(_ keyboardControls: BSKeyboardControls!, selectedField field: UIView!, in direction: BSKeyboardControlsDirection) {
        print("Changed seletion")
        if let scrollView = parentScrollView {
            scrollView.scrollRectToVisible((keyboardControls.activeField.superview?.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls!) {
        resignResponder()
    }
    
    func addTextFieldToKeyboradControlsTextFields(_ textField: UITextField) {
        textFieldsForKeyboardControls.append(textField)
        textFieldsForKeyboardControls      = textFieldsForKeyboardControls.sorted(by: { $0.tag < $1.tag})
        keyboardControls.fields            = textFieldsForKeyboardControls
    }
    
}

