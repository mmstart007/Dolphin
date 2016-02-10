//
//  NetworkController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/22/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation

class NetworkController: NSObject {
    
    static let sharedInstance = NetworkController()
    
    var posts: [Post]      = []
    var likedPosts: [Post] = []
    var pods: [POD]        = []
    var deals: [Deal]      = []
    
    func initializeNetworkController() {
        let user1 = User(name: "John Doe", imageURL: "")
        
        let comment1 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
        let comment2 = PostComment(user: user1, text: "I'll say!", date: NSDate())
        let comment3 = PostComment(user: user1, text: "This is a larger comment than the previos one, I just want to test the cell height!", date: NSDate())
        let comment4 = PostComment(user: user1, text: "This comment is even larger than the other one, and it is loooooooooooooooooooooooooooooooooooooooooooooooooooooong", date: NSDate())
        let comment5 = PostComment(user: user1, text: "Great, the layout on the comments looks awesome!", date: NSDate())
        
        let post1 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: .URL, header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfLikes: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
        let post2 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: false)
        let post3 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of another awesome post!!!", date: NSDate(), numberOfLikes: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
        posts = [post1, post2, post3]
        
        let post4 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: .URL, header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfLikes: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
        let post5 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
        let post6 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of another awesome post!!!", date: NSDate(), numberOfLikes: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
        
        likedPosts = [post4, post5, post6]
        
        let pod1 = POD(name: "Aviation", imageURL: "https://wallpaperscraft.com/image/plane_sky_flying_sunset_64663_3840x1200.jpg", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1, user1], isPrivate: true)
        let pod2 = POD(name: "Engineering", imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRcMgu3PJLY079zBrxFxZRDwl59nuVuluNdF6PtqJvIzoD39YCQKg", lastpostDate: NSDate(), users: [user1, user1, user1], isPrivate: false)
        let pod3 = POD(name: "Electronics", imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUTqYPZGV5hcCSTuoRf_VR1lbN6lFZvGn8ufGPBNCEVRj7gdN3TA", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1], isPrivate: true)
        
        pods = [pod1, pod2, pod3]
        
        let deal1 = Deal(image: "http://www.freelogovectors.net/wp-content/uploads/2013/01/staples-logo.jpg", description: "50% STAPLES purchase of $100 or more", date: NSDate())
        let deal2 = Deal(image: "http://i.ebayimg.com/00/s/NzY4WDEwMjQ=/z/1I4AAOSwDNdVtpOh/$_3.jpg", description: "XBOX ONE (NIB)", date: NSDate())
        let deal3 = Deal(image: "http://ecx.images-amazon.com/images/I/41aawS8-fLL._SY300_.jpg", description: "Ninja Turtles Remote Control Adapter", date: NSDate())
        
        deals.append(deal1)
        deals.append(deal2)
        deals.append(deal3)
    }
    
}
