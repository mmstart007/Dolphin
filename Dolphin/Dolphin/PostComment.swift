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
    var postCommentDate: Date?
    var postCommentImage: UIImage?
    var postCommentIsLike: Int?
    var postCommentLikeCount: Int?
    var postImage: Image?
    var postLink: Link?
    
    convenience init(text: String, image: UIImage?) {
        self.init()
        self.postCommentText = text
        self.postCommentImage = image
    }
    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        let postJsonObject       = jsonObject as? [String: AnyObject]
        
        if let imageJson = postJsonObject!["image"] as? [String: AnyObject] {
            self.postImage = Image(jsonObject: imageJson as AnyObject)
        }
        
        if let linkJson = postJsonObject!["link"] as? [String: AnyObject] {
            self.postLink = Link(jsonObject: linkJson as AnyObject)
        }
        
        self.postCommentLikeCount       = postJsonObject!["likes_count"] as? Int
        self.postCommentIsLike       = postJsonObject!["is_liked"] as? Int
        self.postCommentId       = postJsonObject!["id"] as? Int
        self.postCommentUser     = User(jsonObject: postJsonObject!["user"] as! [String: AnyObject] as AnyObject)
        self.postCommentText     = postJsonObject!["body"] as? String
        let dateString           = postJsonObject!["created_at"] as? String
        self.postCommentDate     = Date(timeIntervalSince1970: Double(dateString!)!)
        
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic = [String: AnyObject]()
        if let text = self.postCommentText {
            retDic["body"] = text as AnyObject?
        }
        if let image = self.postCommentImage {
            retDic["image"] = Utils.encodeBase64(image) as AnyObject?
        }
        return retDic
        
    }
    
}
