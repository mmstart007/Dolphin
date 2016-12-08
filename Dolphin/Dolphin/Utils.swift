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
    
    static func setFontFamilyForView(_ vw: UIView, includeSubViews: Bool) {
        if let label = vw as? UILabel {
            if label.font.familyName.hasSuffix("-Regular") || !label.font.familyName.contains("-") {
                label.font = UIFont(name: "Raleway-Regular", size: label.font.pointSize)
            } else if label.font.familyName.hasSuffix("-Bold") {
                label.font = UIFont(name: "Raleway-Bold", size: label.font.pointSize)
            }
            
        } else if let textField = vw as? UITextField {
            if textField.font!.familyName.hasSuffix("-Regular") || !textField.font!.familyName.contains("-") {
                textField.font = UIFont(name: "Raleway-Regular", size: textField.font!.pointSize)
            } else if textField.font!.familyName.hasSuffix("-Bold") {
                textField.font = UIFont(name: "Raleway-Bold", size: textField.font!.pointSize)
            }
        } else if let button = vw as? UIButton {
            if button.titleLabel!.font.familyName.hasSuffix("-Regular") || !button.titleLabel!.font.familyName.contains("-") {
                button.titleLabel!.font = UIFont(name: "Raleway-Regular", size: button.titleLabel!.font.pointSize)
            } else if button.titleLabel!.font.familyName.hasSuffix("-Bold") {
                button.titleLabel!.font = UIFont(name: "Raleway-Bold", size: button.titleLabel!.font.pointSize)
            }
        } else if let textView = vw as? UITextView {
            if textView.font != nil {
                if textView.font!.familyName.hasSuffix("-Regular") || !textView.font!.familyName.contains("-") {
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
    
    static func presentAlertMessage(_ title: String!, message: String!, cancelActionText: String!, presentingViewContoller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        presentingViewContoller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Dispatch After
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // MARK: - Base64 encoding/decoding
    
    static func encodeBase64(_ srcImage: UIImage) -> String {
        //Now use image to create into NSData format
//        let imageData = UIImagePNGRepresentation(srcImage)
        let imageData = UIImageJPEGRepresentation(srcImage, Constants.Globals.ImageCompression)
        let base64String = imageData!.base64EncodedString(options: .lineLength64Characters)        
        return base64String
    }
    
    static func decodeBase64(_ encodedBase64String: String) -> UIImage? {
        let decodedData = Data(base64Encoded: encodedBase64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        return decodedImage
        
    }
    
    // MARK: - Resize images
    
    static func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK: - Crop images
    static func cropToBounds(_ image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)

        let rect = CGRect(x: 0, y: 0, width: width, height: height)        
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    static func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - Validations
    
    static func verifyUrl (_ urlString: String) -> Bool {
        let webSiteRegEx = "((https?)://)?(([\\w\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\-\\+\\=\\(\\)\\[\\]\\{\\}\\?\\<\\>])*)+([\\.|/](([\\w\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\-\\+\\=\\(\\)\\[\\]\\{\\}\\?\\<\\>])+))+"
        
        let webSitePredicate = NSPredicate(format:"SELF MATCHES %@", webSiteRegEx)
        return webSitePredicate.evaluate(with: urlString)
    }
    
}
