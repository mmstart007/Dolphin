//
//  PostCommentRequest.swift
//  Dolphin
//
//  Created by Mobi Soft on 10/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class PostCommentRequest : NSObject {
    
    var postCommentId: Int?
    var postCommentText: String?
    var postCommentImage: UIImage?
    var type : String?
    var url : String?
    var postImageWidth: Int?
    var postImageHeight: Int?
    var postImageUrl: String?
    
    convenience init(text: String, image: UIImage?, type : String?, url : String?, imageWidth: Int?, imageHeight: Int?) {
        self.init()
        self.postCommentText = text
        self.postCommentImage = image
        self.type = type
        self.url = url
        self.postImageWidth = imageWidth
        self.postImageHeight = imageHeight
    }

    func toJson() -> [String: AnyObject] {
        var retDic = [String: AnyObject]()
        if let text = self.postCommentText {
            retDic["body"] = text
        }
        if let image = self.postCommentImage {
            retDic["image"] = Utils.encodeBase64(image)
        }
        if let type = self.type {
            retDic["type"] = type
        }
        if let url = self.url {
            retDic["url"] = url
        }
        
        if let imageUrl = self.postImageUrl {
            retDic["image_url"] = imageUrl
        }
        
        if let image_width = self.postImageWidth {
            retDic["image_width"] = image_width
        }
        
        if let image_height = self.postImageHeight {
            retDic["image_height"] = image_height
        }
        
        
        return retDic
    }
}


