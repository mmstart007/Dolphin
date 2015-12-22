//
//  Post.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/27/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class Post : NSObject {
    
    enum PostType: String {
     
        case URL = "URL", Photo = "PHOTO", Text = "TEXT"
        
    }
    
    func postColor() -> UIColor {
        switch(self.postType!) {
        case .URL:
            return UIColor(red: 155/255.0, green: 230/255.0, blue: 88/255.0, alpha: 1)
        case .Photo:
            return UIColor(red: 40/255.0, green: 231/255.0, blue: 216/255.0, alpha: 1)
        case .Text:
            return UIColor(red: 232/255.0, green: 97/255.0, blue: 39/255.0, alpha: 1)
        }
    }
    
    var postUser: User?
    var postImageURL: String?
    var postType: PostType?
    var postHeader: String?
    var postText: String?
    var postDate: NSDate?
    var postNumberOfLikes: Int?
    var postNumberOfComments: Int?
    var postComments: [PostComment]?
    var isLikedByUser: Bool
    
    init(user: User, imageURL: String, type: PostType, header: String, text: String, date: NSDate,
        numberOfLikes: Int, numberOfComments: Int, comments: [PostComment], isLiked: Bool) {
        self.postUser             = user
        self.postImageURL         = imageURL
        self.postType             = type
        self.postHeader           = header
        self.postText             = text
        self.postDate             = date
        self.postNumberOfLikes    = numberOfLikes
        self.postNumberOfComments = numberOfComments
        self.postComments         = comments
        self.isLikedByUser        = isLiked
    }
}