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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackButton() {
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "NavBarGoBackButton"), style: UIBarButtonItemStyle.Plain, target: self, action:"goBackButtonPressed:")
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func setDismissButton() {
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissButtonPressed:")
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    
    func goBackButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setRightSystemButtonItem(systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setRightButtonItemWithText(text: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(title: text, style: .Plain, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func addRightButtonItemWithImage(imageName: String, target: AnyObject?, action: Selector) {
        let rightButton = UIBarButtonItem(image: UIImage(named: imageName), style: .Plain, target: target, action: action)
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItems?.append(rightButton)
    }
    
    func resignResponder() {
        if let firstResponder = view.findViewThatIsFirstResponder() {
            firstResponder.resignFirstResponder()
        }
    }
    
    // MARK: Handle Keyboard showing
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let activeView = self.view.findViewThatIsFirstResponder() {
            if let keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                parentScrollView?.contentInset = contentInsets
                parentScrollView?.scrollIndicatorInsets = contentInsets
                var aRect = self.view.frame
                aRect.size.height -= keyboardSize.height;
                let activeViewAbsoluteFrame = activeView.convertRect(activeView.frame, toView: nil)
                let distance = (UIScreen.mainScreen().bounds.height - keyboardSize.height) - (activeViewAbsoluteFrame.origin.y + activeViewAbsoluteFrame.size.height)
                if !CGRectContainsPoint(aRect, activeViewAbsoluteFrame.origin) {
                    parentScrollView?.scrollRectToVisible(activeViewAbsoluteFrame, animated: true)
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInsets = UIEdgeInsetsZero
        parentScrollView?.contentInset = contentInsets
        parentScrollView?.scrollIndicatorInsets = contentInsets
        
    }
    
    // MARK: - Keyboard Controls
    
    func keyboardControls(keyboardControls: BSKeyboardControls!, selectedField field: UIView!, inDirection direction: BSKeyboardControlsDirection) {
        print("Changed seletion")
        if let scrollView = parentScrollView as! UIScrollView? {
            scrollView.scrollRectToVisible((keyboardControls.activeField.superview?.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardControlsDonePressed(keyboardControls: BSKeyboardControls!) {
        resignResponder()
    }
    
    func addTextFieldToKeyboradControlsTextFields(textField: UITextField) {
        textFieldsForKeyboardControls.append(textField)
        textFieldsForKeyboardControls      = textFieldsForKeyboardControls.sort({ $0.tag < $1.tag})
        keyboardControls.fields            = textFieldsForKeyboardControls
    }
    
}

