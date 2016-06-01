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
        case "link":
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
    var postPODId: Int?
    var postUser: User?
    var postImage: Image?
    var postImageData: UIImage?
    var postType: PostType?
    var postTopics: [Topic]?
    var postLink: Link?
    var postImageUrl: String?
    var postImageWidth: Float?
    var postImageHeight: Float?
    var postHeader: String?
    var postText: String?
    var postDate: NSDate?
    var postNumberOfLikes: Int?
    var postNumberOfComments: Int?
    var postComments: [PostComment]?
    var isLikedByUser: Bool = false
    
    convenience init(user: User?, image: Image?, imageData: UIImage?, imageWidth: Float?, imageHeight: Float?, type: PostType?,
        topics: [Topic]?, link: Link?, imageUrl: String?, title: String?, text: String?,
        date: NSDate?, numberOfLikes: Int?, numberOfComments: Int?, comments: [PostComment]?, PODId: Int?) {
            self.init()
            
            self.postPODId            = PODId
            self.postUser             = user
            self.postImage            = image
            self.postImageData        = imageData
            self.postImageWidth       = imageWidth
            self.postImageHeight      = imageHeight
            self.postType             = type
            self.postTopics           = topics
            self.postLink             = link
            self.postImageUrl         = imageUrl
            self.postHeader           = title
            self.postText             = text
            self.postDate             = date
            self.postNumberOfLikes    = numberOfLikes
            self.postNumberOfComments = numberOfComments
            self.postComments         = comments
    }
    
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
        if let linkJson = postJsonObject!["link"] as? [String: AnyObject] {
            self.postLink = Link(jsonObject: linkJson)
        }
        self.postTopics = []
        if let topicsJsonArray = postJsonObject!["topics"] as? [[String: AnyObject]] {
            for elem in topicsJsonArray {
                self.postTopics?.append(Topic(jsonObject: elem))
            }
        }
        if let likeIt = postJsonObject!["is_liked"] as? Int {
            self.isLikedByUser = likeIt == 1
        }
        
        self.postNumberOfLikes    = postJsonObject!["likes_count"] as? Int
        self.postNumberOfComments = postJsonObject!["comments_count"] as? Int
        self.postText             = postJsonObject!["body"] as? String
        self.postHeader           = postJsonObject!["title"] as? String
        self.postId               = postJsonObject!["id"] as? Int
        self.postImageUrl         = postJsonObject!["image_url"] as? String
        let dateString            = postJsonObject!["created_at"] as? String
        let dateFormatter         = NSDateFormatter()
        dateFormatter.dateFormat  = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
        self.postDate             = dateFormatter.dateFromString(dateString!)
        self.postComments         = []
        
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = ["type": self.postType!.name!]
        if let title = self.postHeader {
            retDic["title"] = title
        }
        if let body = self.postText {
            retDic["body"] = body
        }
        if let link = self.postLink {
            retDic["url"] = link.url
            retDic["image_url"] = link.imageURL
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
        
        if let topics = self.postTopics {
            var topicsNames: [String] = []
            for t in topics {
                topicsNames.append(t.name!)
            }
            retDic["topics"] = topicsNames
        }
        if let image = self.postImageData {
            retDic["image"] = Utils.encodeBase64(image)
        }
        if let podId = self.postPODId {
            retDic["pod_id"] = podId
        }
        return retDic
    }
}