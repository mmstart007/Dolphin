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
    
    // MARK: - Dispatch After
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // MARK: - Base64 encoding/decoding
    
    static func encodeBase64(srcImage: UIImage) -> String {
        //Now use image to create into NSData format
        let imageData = UIImagePNGRepresentation(srcImage)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)        
        return base64String

    }
    
    static func decodeBase64(encodedBase64String: String) -> UIImage? {
        let decodedData = NSData(base64EncodedString: encodedBase64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        return decodedImage
        
    }
    
    // MARK: - Resize images
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - Crop images
    static func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)

        let rect = CGRectMake(0, 0, width, height)        
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
}