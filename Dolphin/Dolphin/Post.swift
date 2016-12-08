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
            return UIColor.black
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
    var postDate: Date?
    var postNumberOfLikes: Int?
    var postNumberOfComments: Int?
    var postComments: [PostComment]?
    var isLikedByUser: Bool = false
    
    convenience init(user: User?, image: Image?, imageData: UIImage?, imageWidth: Float?, imageHeight: Float?, type: PostType?,
        topics: [Topic]?, link: Link?, imageUrl: String?, title: String?, text: String?,
        date: Date?, numberOfLikes: Int?, numberOfComments: Int?, comments: [PostComment]?, PODId: Int?) {
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
            self.postUser  = User(jsonObject: userJson as AnyObject)
        }
        if let imageJson = postJsonObject!["image"] as? [String: AnyObject] {
            self.postImage = Image(jsonObject: imageJson as AnyObject)
        }
        if let typeJson = postJsonObject!["type"] as? [String: AnyObject] {
            self.postType = PostType(jsonObject: typeJson as AnyObject)
        }
        if let linkJson = postJsonObject!["link"] as? [String: AnyObject] {
            self.postLink = Link(jsonObject: linkJson as AnyObject)
        }
        self.postTopics = []
        if let topicsJsonArray = postJsonObject!["topics"] as? [[String: AnyObject]] {
            for elem in topicsJsonArray {
                self.postTopics?.append(Topic(jsonObject: elem as AnyObject))
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
        self.postDate             = Date(timeIntervalSince1970: Double(dateString!)!)
        self.postComments         = []
        
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = ["type": self.postType!.name! as AnyObject]
        if let title = self.postHeader {
            retDic["title"] = title as AnyObject?
        }
        if let body = self.postText {
            retDic["body"] = body as AnyObject?
        }
        if let link = self.postLink {
            retDic["url"] = link.url as AnyObject?
            retDic["image_url"] = link.imageURL as AnyObject?
        }
        if let imageUrl = self.postImageUrl {
            retDic["image_url"] = imageUrl as AnyObject?
        }
        
        if let image_width = self.postImageWidth {
            retDic["image_width"] = image_width as AnyObject?
        }
        
        if let image_height = self.postImageHeight {
            retDic["image_height"] = image_height as AnyObject?
        }
        
        if let topics = self.postTopics {
            var topicsNames: [String] = []
            for t in topics {
                topicsNames.append(t.name!)
            }
            retDic["topics"] = topicsNames as AnyObject?
        }
        if let image = self.postImageData {
            retDic["image"] = Utils.encodeBase64(image) as AnyObject?
        }
        if let podId = self.postPODId {
            retDic["pod_id"] = podId as AnyObject?
        }
        return retDic
    }
}
