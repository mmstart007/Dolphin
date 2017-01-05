//
//  Post.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        //let postJsonObject = jsonObject as? [String: AnyObject]
        //if let userJson = postJsonObject!["user"] as? [String: AnyObject] {
            self.postUser  = User(jsonObject: jsonObject["user"])
        //}
        //if let imageJson = postJsonObject!["image"] as? [String: AnyObject] {
            self.postImage = Image(jsonObject: jsonObject["image"])
        //}
        //if let typeJson = postJsonObject!["type"] as? [String: AnyObject] {
            self.postType = PostType(jsonObject: jsonObject["type"])
        //}
        //if let linkJson = postJsonObject!["link"] as? [String: AnyObject] {
            self.postLink = Link(jsonObject: jsonObject["link"])
        //}
        self.postTopics = []
        if let topicsJsonArray = jsonObject["topics"].array {
            for elem in topicsJsonArray {
                self.postTopics?.append(Topic(jsonObject: elem))
            }
        }
        //if let likeIt = jsonObject["is_liked"].intValue {
            self.isLikedByUser = jsonObject["is_liked"] == 1
        //}
        
        self.postNumberOfLikes    = jsonObject["likes_count"].intValue
        self.postNumberOfComments = jsonObject["comments_count"].intValue
        self.postText             = jsonObject["body"].stringValue
        self.postHeader           = jsonObject["title"].stringValue
        self.postId               = jsonObject["id"].intValue
        self.postImageUrl         = jsonObject["image_url"].stringValue
        let dateString            = jsonObject["created_at"].stringValue
        self.postDate             = Date(timeIntervalSince1970: Double(dateString)!)
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
