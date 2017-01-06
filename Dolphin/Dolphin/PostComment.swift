//
//  PostComment.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    init(text: String, image: UIImage?) {
        //self.init()
        self.postCommentText = text
        self.postCommentImage = image
    }
    
    init(jsonObject: JSON) {
        //self.init()
        
        let postJsonObject       = jsonObject
        
        self.postImage = Image(jsonObject: postJsonObject["image"])
        self.postLink = Link(jsonObject: postJsonObject["link"])
        
        self.postCommentLikeCount       = postJsonObject["likes_count"].intValue
        self.postCommentIsLike       = postJsonObject["is_liked"].intValue
        self.postCommentId       = postJsonObject["id"].intValue
        self.postCommentUser     = User(jsonObject: postJsonObject["user"])
        self.postCommentText     = postJsonObject["body"].stringValue
        let dateString           = postJsonObject["created_at"].stringValue
        self.postCommentDate     = Date(timeIntervalSince1970: Double(dateString)!)
        
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
