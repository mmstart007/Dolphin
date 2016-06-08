//
//  PostComment.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class PostComment : NSObject {
    
    var postCommentId: Int?
    var postCommentUser: User?
    var postCommentText: String?
    var postCommentDate: NSDate?
    var postCommentImage: UIImage?
    
    convenience init(text: String, image: UIImage?) {
        self.init()
        self.postCommentText = text
        self.postCommentImage = image
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        let postJsonObject       = jsonObject as? [String: AnyObject]

        self.postCommentId       = postJsonObject!["id"] as? Int
        self.postCommentUser     = User(jsonObject: postJsonObject!["user"] as! [String: AnyObject])
        self.postCommentText     = postJsonObject!["body"] as? String
        let dateString           = postJsonObject!["created_at"] as? String
        self.postCommentDate     = NSDate(timeIntervalSince1970: Double(dateString!)!)
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic = [String: AnyObject]()
        if let text = self.postCommentText {
            retDic["body"] = text
        }
        if let image = self.postCommentImage {
            retDic["image"] = Utils.encodeBase64(image)
        }
        return retDic
        
    }
    
}