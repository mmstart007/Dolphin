//
//  UIImage+ScaleAndCrop.swift
//  Deel
//
//  Created by Ninth Coast on 11/18/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    
    func imageByScalingAndCroppingForSize(_ targetSize: CGSize) -> UIImage?
    {
        let sourceImage: UIImage = self
        var newImage: UIImage?
        let imageSize: CGSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        var scaleFactor = 0.0 as CGFloat
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x: 0.0,y: 0.0)
        
        if (imageSize.equalTo(targetSize) == false)
        {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            
            if (widthFactor > heightFactor)
            {
                scaleFactor = widthFactor // scale to fit height
            }
            else
            {
                scaleFactor = heightFactor // scale to fit width
            }
            
            scaledWidth  = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            // center the image
            if widthFactor > heightFactor
            {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }
            else
            {
                if widthFactor < heightFactor
                {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
        }
        
        UIGraphicsBeginImageContext(targetSize) // this will crop
        
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.draw(in: thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if newImage == nil
        {
            print("could not scale image")
        }
        
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
}
