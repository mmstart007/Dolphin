//
//  PostRequest.swift
//  Dolphin
//
//  Created by Mobi Soft on 10/8/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class PostRequest : NSObject {
    
    
    var postId: Int?
    var postPODId: Int?
    var postImage: Image?
    var postImageData: UIImage?
    var postType: String?
    var postTopics: [Topic]?
    var postLink: Link?
    var postImageUrl: String?
    var postImageWidth: Float?
    var postImageHeight: Float?
    var postHeader: String?
    var postText: String?
    
    convenience init(image: Image?, imageData: UIImage?, imageWidth: Float?, imageHeight: Float?, type: String?,topics: [Topic]?, link: Link?, imageUrl: String?, title: String?, text: String?, PODId: Int?, PostId : Int?) {
        self.init()
        
        self.postPODId            = PODId
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
        self.postId               = PostId
    }
    
    
    func toJson() -> [String: AnyObject] {
        var retDic: [String: AnyObject] = ["type": self.postType! as AnyObject]
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
        
        if let postId = self.postId {
            retDic["id"] = postId as AnyObject?
        }
        return retDic
    }
}
