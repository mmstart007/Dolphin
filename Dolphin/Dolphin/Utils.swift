//
//  Utils.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/23/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation


class Utils {
    
    // MARK: Font customization
    
    static func setFontFamilyForView(vw: UIView, includeSubViews: Bool) {
        if let label = vw as? UILabel {
            if label.font.familyName.hasSuffix("-Regular") || !label.font.familyName.containsString("-") {
                label.font = UIFont(name: "Raleway-Regular", size: label.font.pointSize)
            } else if label.font.familyName.hasSuffix("-Bold") {
                label.font = UIFont(name: "Raleway-Bold", size: label.font.pointSize)
            }
            
        } else if let textField = vw as? UITextField {
            if textField.font!.familyName.hasSuffix("-Regular") || !textField.font!.familyName.containsString("-") {
                textField.font = UIFont(name: "Raleway-Regular", size: textField.font!.pointSize)
            } else if textField.font!.familyName.hasSuffix("-Bold") {
                textField.font = UIFont(name: "Raleway-Bold", size: textField.font!.pointSize)
            }
        } else if let button = vw as? UIButton {
            if button.titleLabel!.font.familyName.hasSuffix("-Regular") || !button.titleLabel!.font.familyName.containsString("-") {
                button.titleLabel!.font = UIFont(name: "Raleway-Regular", size: button.titleLabel!.font.pointSize)
            } else if button.titleLabel!.font.familyName.hasSuffix("-Bold") {
                button.titleLabel!.font = UIFont(name: "Raleway-Bold", size: button.titleLabel!.font.pointSize)
            }
        } else if let textView = vw as? UITextView {
            if textView.font != nil {
                if textView.font!.familyName.hasSuffix("-Regular") || !textView.font!.familyName.containsString("-") {
                    textView.font = UIFont(name: "Raleway-Regular", size: textView.font!.pointSize)
                } else if textView.font!.familyName.hasSuffix("-Bold") {
                    textView.font = UIFont(name: "Raleway-Bold", size: textView.font!.pointSize)
                }
                
            } else {
                textView.font = UIFont(name: "Raleway-Regular", size: 12)
            }
        }
        
        if includeSubViews {
            for subView in vw.subviews {
                setFontFamilyForView(subView, includeSubViews: true)
            }
        }
        
    }
    
    // MARK: Alert messages
    
    static func presentAlertMessage(title: String, message: String, cancelActionText: String, presentingViewContoller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelActionText, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentingViewContoller.presentViewController(alert, animated: true, completion: nil)
    }
    
}