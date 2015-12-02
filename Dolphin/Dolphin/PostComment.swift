//
//  PostComment.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/30/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class PostComment : NSObject {
    
    var postCommentUser: User?
    var postCommentText: String?
    var postCommentDate: NSDate?
    
    init(user: User, text: String, date: NSDate) {
        self.postCommentUser = user
        self.postCommentText = text
        self.postCommentDate = date
    }
    
}