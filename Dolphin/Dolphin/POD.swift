//
//  POD.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/1/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import SwiftyJSON

class POD : NSObject {
    
    var id: Int?
    var name: String?
    var descriptionText: String?
    var imageURL: String?
    var imageData: UIImage?
    var isPrivate: Int?
    var owner: User?
    var users: [User]?
    var postsCount: Int?
    var usersCount: Int?
    var lastPostDate: Date?
    var image_width: Int?
    var image_height: Int?
    var total_unread: Int?
    var isMyFeed : Bool?

    
    convenience init(name: String?, description: String?, imageURL: String?, isPrivate: Int?, owner: User?, users: [User]?, postsCount: Int?, usersCount: Int?, imageData: UIImage?, image_width: Int?, image_height: Int?,total_unread: Int?) {

        self.init()
        
        self.name            = name
        self.descriptionText = description
        self.imageURL        = imageURL
        self.isPrivate       = isPrivate
        self.owner           = owner
        self.users           = users
        self.postsCount      = postsCount
        self.usersCount      = usersCount
        self.imageData       = imageData
        self.image_width     = image_width
        self.image_height    = image_height
        self.total_unread    = total_unread

    }
    
    func podColor() -> UIColor {
        let color = Int(arc4random_uniform(3))
        let colors = [UIColor(red: 155/255.0, green: 230/255.0, blue: 88/255.0, alpha: 1), UIColor(red: 40/255.0, green: 231/255.0, blue: 216/255.0, alpha: 1),
            UIColor(red: 232/255.0, green: 97/255.0, blue: 39/255.0, alpha: 1)]
        return colors[color]
    }
    
    convenience init(jsonObject: JSON) {
        self.init()
        
        //let podJsonObject = jsonObject as? [String: AnyObject]
        //if let ownerJson = jsonObject["owner"] { //as? [String: AnyObject] {
            self.owner  = User(jsonObject: jsonObject["owner"])
        //}
        self.users = jsonObject["users"].array?.map({ (elem) -> User in
            User(jsonObject: elem)
        })
        
        /*self.users = jsonObject["users"].array.map({ (actual) -> User in
            User(jsonObject: actual)
        }) */
        
        self.id              = jsonObject["id"].intValue
        self.name            = jsonObject["name"].stringValue
        self.descriptionText = jsonObject["description"].stringValue
        self.imageURL        = jsonObject["image_url"].stringValue
        self.isPrivate       = jsonObject["is_private"].intValue
        self.image_width     = jsonObject["image_width"].intValue
        self.image_height    = jsonObject["image_height"].intValue
        self.total_unread    = jsonObject["total_unread"].intValue
        
        if let lastPostsJson = jsonObject["last_post"].array { // as? [AnyObject] {
            if lastPostsJson.count > 0 {
                if let lastPostJson = lastPostsJson.first { // as? [String: AnyObject] {
                    let dateString = lastPostJson["created_at"].stringValue
                    self.lastPostDate     = Date(timeIntervalSince1970: Double(dateString)!)
                }
            }
        }
    }
    
    func toJson() -> [String: AnyObject] {
        var retDic = [String: AnyObject]()
        if let podId = self.id {
            retDic["id"] = podId as AnyObject?
        }
        
        if let nm = self.name {
            retDic["name"] = nm as AnyObject?
        }
        if let descrip = self.descriptionText {
            retDic["description"] = descrip as AnyObject?
        }
        if let image = self.imageData {
            retDic["image"] = Utils.encodeBase64(image) as AnyObject?
        }
        if let priv = self.isPrivate {
            retDic["is_private"] = priv as AnyObject?
        }
        if let width = self.image_width {
            retDic["image_width"] = width as AnyObject?
        }
        if let height = self.image_height {
            retDic["image_height"] = height as AnyObject?
        }
        
        if let usrs = self.users {
            let usersIds: [Int]? = usrs.map({ (actual) -> Int in
                actual.id!
            })
            retDic["users"] = usersIds as AnyObject?
        }
        
        return retDic
    }
    
}
