//
//  UIView+DolphinExtensions.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

extension UIView {
    
    func findViewThatIsFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        } else {
            for subView: UIView in self.subviews {
                let firstresponder = subView.findViewThatIsFirstResponder()
                if firstresponder != nil {
                    return firstresponder
                }
            }
        }
        
        return nil
    }
    
}
