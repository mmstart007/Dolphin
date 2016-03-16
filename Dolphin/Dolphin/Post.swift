//
//  Post.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class Post : NSObject {
    
    func postColor() -> UIColor {
        switch(self.postType!.name!) {
        case "url":
            return UIColor(red: 155/255.0, green: 230/255.0, blue: 88/255.0, alpha: 1)
        case "image":
            return UIColor(red: 40/255.0, green: 231/255.0, blue: 216/255.0, alpha: 1)
        case "text":
            return UIColor(red: 232/255.0, green: 97/255.0, blue: 39/255.0, alpha: 1)
        default:
            return UIColor.blackColor()
        }
    }
    
    var postId: Int?
    var postUser: User?
    var postImage: Image?
    var postType: PostType?
    var postTopics: [Topic]?
    var postHeader: String?
    var postText: String?
    var postDate: NSDate?
    var postNumberOfLikes: Int?
    var postNumberOfComments: Int?
    var postComments: [PostComment]?
    var isLikedByUser: Bool = false
    

    
    convenience init(jsonObject: AnyObject) {
        self.init()
        
        let postJsonObject = jsonObject as? [String: AnyObject]
        if let userJson = postJsonObject!["user"] as? [String: AnyObject] {
            self.postUser  = User(jsonObject: userJson)
        }
        if let imageJson = postJsonObject!["image"] as? [String: AnyObject] {
            self.postImage = Image(jsonObject: imageJson)
        }
        if let typeJson = postJsonObject!["type"] as? [String: AnyObject] {
            self.postType = PostType(jsonObject: typeJson)
        }
        self.postTopics = []
        if let topicsJsonArray = postJsonObject!["topics"] as? [[String: AnyObject]] {
            for elem in topicsJsonArray {
                self.postTopics?.append(Topic(jsonObject: elem))
            }
        }
        self.postNumberOfLikes    = postJsonObject!["likes_count"] as? Int
        self.postNumberOfComments = postJsonObject!["comments_count"] as? Int
        self.postText             = postJsonObject!["body"] as? String
        self.postHeader           = postJsonObject!["title"] as? String
        self.postId               = postJsonObject!["id"] as? Int
        let dateString            = postJsonObject!["created_at"] as? String
        let dateFormatter         = NSDateFormatter()
        dateFormatter.dateFormat  = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
        self.postDate             = dateFormatter.dateFromString(dateString!)
        self.postComments         = []
        
    }
}