//
//  NetworkController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/22/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NetworkController: NSObject {
    
    static let sharedInstance = NetworkController()
    
    let baseUrl                = Constants.RESTAPIConfig.Developement.BaseUrl
    let apiVersion: ApiVersion = ApiVersion.V1;
    var basePath: String {
        get {
            return Constants.RESTAPIConfig.Developement.BaseUrl + "api/" + apiVersion.rawValue + "/"
        }
    }

    var token: String?
    var posts: [Post]      = []
//    var likedPosts: [Post] = []
    var pods: [POD]        = []
    var deals: [Deal]      = []
    var currentUserId: Int?
    var currentUser: User?
    
    enum MethodType: String {
        case PUT    = "PUT"
        case POST   = "POST"
        case GET    = "GET"
        case DELETE = "DELETE"
        case PATCH  = "PATCH"
    }
    
    enum ApiVersion: String {
        case V1 = "v1"
    }
    
    enum ApiMethod: String {
        case Login              = "login"
        case User               = "users"
        case FilterUser         = "users/filter"
        case GetUserById        = "users/%@"
        case GetUserLikes       = "users/%@/likes"
        case GetUserLikePost    = "users/%@/likes/%@"
        case GetUserComments    = "users/%@/comments"
        case LikeComment        = "posts/%@/comments/%@/likes"

        case GetSubjects        = "subjects"
        case GetGrades          = "grades"
        case CreatePost         = "posts"
        case FilterPost         = "posts/filter"
        case PostById           = "posts/%@"
        case PostComments       = "posts/%@/comments"
        case PostLikes          = "posts/%@/likes"
        case PostReport         = "posts/%@/reports"
        case PostShare          = "posts/%@/shares"
        case PostOpen           = "posts/%@/opens"
        case CreateTopic        = "topics"
        case TopicById          = "topics/%@"
        case TopicByUser        = "topics/user/%@"
        case FilterTopic        = "topics/filter"
        
        case CreatePOD          = "pods"
        case FilterPOD          = "pods/filter"
        case PODById            = "pods/%@"
        case PodMember          = "pods/%@/users/%@"
        case JoinInPod          = "pods/%@/users/join"
        
        case FilterNotification    = "notifications/filter"
    }
    
    // MARK: - Public Methods
    // MARK: - USERS
    
    func login(_ userName: String, password: String, completionHandler: @escaping (User?, String?, Int?, AnyObject?) -> ()) -> () {
        var retToken: String?
        var retUserId: Int?
        var loginParams = ["username": userName, "password": password]
        if Globals.currentDeviceToken.characters.count > 0 {
            loginParams["device_token"] = Globals.currentDeviceToken
        }
        
        let parameters : [String : AnyObject]? = ["login": loginParams as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .Login, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                
                let jsonObject = JSON(result!)
                
                retToken = jsonObject["token"].stringValue
                let retUser = jsonObject["user"]
                retUserId = jsonObject["id"].intValue
                self.token = retToken
                self.currentUserId = retUserId
                self.currentUser = User(jsonObject: retUser)
                completionHandler(self.currentUser, retToken, retUserId, nil)
            } else {
                completionHandler(self.currentUser, retToken, retUserId, error)
            }
        }
        
    }
    
    func registerUser(_ user: User, completionHandler: @escaping (User?, String?, Int?, AnyObject?) -> ()) -> () {
        var retToken: String?
        var retUserId: Int?
        var userInfo = user.toJson()
        
        if Globals.currentDeviceToken.characters.count > 0 {
            userInfo["device_token"] = Globals.currentDeviceToken as AnyObject?
        }
        
        let parameters = ["user": userInfo]
        performRequest(MethodType.POST, authenticated: false, method: .User, urlParams: nil, params: parameters as [String : AnyObject]?, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                
                let jsonObject = JSON(result!)
                
                retToken = jsonObject["api_token"].stringValue
                let retUser = jsonObject["user"]
                retUserId = jsonObject["id"].intValue
                self.token = retToken
                self.currentUserId = retUserId
                self.currentUser = User(jsonObject: retUser)
                completionHandler(self.currentUser, retToken, retUserId, nil)
            } else {
                completionHandler(nil, retToken, retUserId, error)
            }
        }
    }
    
    func updateUser(_ userName: String?,
                    deviceId: String?,
                    firstName: String?,
                    lastName: String?,
                    avatarImage: String?,
                    email: String?,
                    password: String?,
                    gender: Int?,
                    city: String?,
                    country: String?,
                    zip: String?,
                    location: String?,
                    isPrivate: Int?,
                    subjects: [String]?,
                    grades: [String]?,
                    completionHandler: @escaping (User?, AnyObject?) -> ()) -> () {
        
        var userUpdated: User?
        var updateValues = [String: AnyObject]()
        if userName != nil {
            updateValues["username"] = userName as AnyObject?
        }
        if deviceId != nil {
            updateValues["device_id"] = deviceId as AnyObject?
        }
        if firstName != nil {
            updateValues["first_name"] = firstName as AnyObject?
        }
        if lastName != nil {
            updateValues["last_name"] = lastName as AnyObject?
        }
        if gender != nil {
            updateValues["gender"] = gender as AnyObject?
        }
        if city != nil {
            updateValues["city"] = city as AnyObject?
        }
        if country != nil {
            updateValues["country"] = country as AnyObject?
        }
        if zip != nil {
            updateValues["zip"] = zip as AnyObject?
        }
        if avatarImage != nil {
            updateValues["avatar_image"] = avatarImage as AnyObject?
        }
        if email != nil {
            updateValues["email"] = email as AnyObject?
        }
        if password != nil {
            updateValues["password"] = password as AnyObject?
        }
        if location != nil {
            updateValues["location"] = location as AnyObject?
        }
        if isPrivate != nil {
            updateValues["is_private"] = isPrivate! as AnyObject?
        }
        if grades != nil {
            updateValues["grades"] = grades as AnyObject?
        }
        if subjects != nil {
            updateValues["subjects"] = subjects as AnyObject?
        }
        let parameters : [String : AnyObject]? = ["user": updateValues as AnyObject]
        performRequest(MethodType.PATCH, authenticated: true, method: .User, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let userRet = result!["user"] {
                    userUpdated = User(jsonObject: userRet as! JSON)
                }
                completionHandler(userUpdated, nil)
            } else {
                completionHandler(userUpdated, error)
            }
        }
    }
    
    func filterUser(_ pattern: String?, podId: Int?, fromDate: Date?, toDate: Date?, quantity: Int?, page: Int?, completionHandler: @escaping ([User], AnyObject?) -> ()) -> () {
        var users: [User] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern as AnyObject?
        }
        if podId != nil {
            filters["pod_id"] = podId as AnyObject?
        }
        if fromDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: fromDate!)
            filters["from_date"]     = dateString as AnyObject?
        }
        if toDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: toDate!)
            filters["to_date"]       = dateString as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterUser, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let usersJsonArray = jsonObject["users"].arrayValue
                if usersJsonArray.count > 0 {
                    for elem in usersJsonArray {
                        users.append(User(jsonObject: elem))
                    }
                }
                completionHandler(users, nil)
            } else {
                completionHandler(users, error)
            }
        }
    }
    
    func getUserById(_ userId: String, completionHandler: @escaping (User?, AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let userJson = jsonObject["user"]
                let user = User(jsonObject: userJson)
                completionHandler(user, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        
    }
    
    func getUserLikes(_ userId: String, completionHandler: @escaping ([Like], AnyObject?) -> ()) -> () {
        var userLikes: [Like] = []
        let urlParameters : [CVarArg] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let userLikesJsonArray = jsonObject["likes"].array
                for elem in userLikesJsonArray! {
                    userLikes.append(Like(jsonObject: elem))
                }
                completionHandler(userLikes, nil)
            } else {
                completionHandler(userLikes, error)
            }
        }
        
    }
    
    func getUserLikePost(_ userId: String, postId: String, completionHandler: @escaping (Bool, AnyObject?) -> ()) -> () {
        var userLikePost: Bool = false
        let urlParameters : [CVarArg] = [userId, postId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserLikePost, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let userLikeJsonArray = jsonObject["likes"].arrayValue
                let userLikeJson = userLikeJsonArray[0]
                userLikePost = userLikeJson["id"].boolValue
                completionHandler(userLikePost, nil)
            } else {
                completionHandler(userLikePost, error)
            }
        }
        
    }
    
    
    func getUserComments(_ userId: String, completionHandler: @escaping ([PostComment], AnyObject?) -> ()) -> () {
        var userComments: [PostComment] = []
        let urlParameters : [CVarArg] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserComments, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let userCommentsJsonArray = jsonObject["comments"].array
                for elem in userCommentsJsonArray! {
                    userComments.append(PostComment(jsonObject: elem))
                }
                completionHandler(userComments, nil)
            } else {
                completionHandler(userComments, error)
            }
        }
    }
    
    
    // MARK: - Grades and Subjects.
    func getSubjects(_ completionHandler: @escaping ([Subject]?, AnyObject?) -> ()) -> () {
        var subjects: [Subject] = []
        performRequest(MethodType.GET, authenticated: true, method: .GetSubjects, urlParams: nil, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let arraySubjects = jsonObject.array
                for elem in arraySubjects! {
                    subjects.append(Subject(jsonObject: elem))
                }
                completionHandler(subjects, nil)
            } else {
                completionHandler(subjects, error)
            }
        }
    }
    
    func getGrades(_ completionHandler: @escaping ([Grade]?, AnyObject?) -> ()) -> () {
        var grades: [Grade ] = []
        performRequest(MethodType.GET, authenticated: true, method: .GetGrades, urlParams: nil, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let arraySubjects = jsonObject.array
                for elem in arraySubjects! {
                    grades.append(Grade(jsonObject: elem))
                }
                completionHandler(grades, nil)
            } else {
                completionHandler(grades, error)
            }
        }
    }
    
    func updateGradesAndSubjects(_ grades: [String]?, subjects: [String]?, completionHandler: @escaping (User?, AnyObject?) -> ()) -> () {
        var user = [String: AnyObject]()
        user["grades"] = grades as AnyObject?
        user["subjects"] = subjects as AnyObject?

        let parameters : [String : AnyObject]? = ["user": user as AnyObject]
        
        print(parameters!)
        performRequest(MethodType.PATCH, authenticated: true, method: .User, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let retUser = jsonObject["user"]
                self.currentUser = User(jsonObject: retUser)
                completionHandler(self.currentUser, nil)
            } else {
                completionHandler(self.currentUser, error)
            }
        }
    }
    
    // MARK: - POSTS
    func createPost(_ post: Post, completionHandler: @escaping (Post?, AnyObject?) -> ()) -> () {
        var savedPost: Post?
        let parameters : [String : AnyObject]? = ["post": post.toJson() as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .CreatePost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["post"].arrayValue.count > 0 {
                    savedPost = Post(jsonObject: jsonObject["post"].arrayValue.first!)
                }
                /*if let postJson = jsonObject["post"] as? [[String: AnyObject]] {
                    savedPost = Post(jsonObject: postJson.first as! JSON)
                } */
                completionHandler(savedPost, nil)
            } else {
                completionHandler(savedPost, error)
            }
        }
    }
    
    func updatePost(_ post: PostRequest, completionHandler: @escaping (Post?, AnyObject?) -> ()) -> () {
        var savedPost: Post?
        let parameters : [String : AnyObject]? = ["post": post.toJson() as AnyObject]
        
        //var error : NSError?
        
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        performRequest(MethodType.PATCH, authenticated: true, method: .CreatePost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["post"].arrayValue.count > 0 {
                    savedPost = Post(jsonObject: jsonObject["post"].arrayValue.first!)
                }
                /*if let postJson = result!["post"] as? [[String: AnyObject]] {
                    savedPost = Post(jsonObject: postJson[0] as! JSON)
                } */
                completionHandler(savedPost, nil)
            } else {
                completionHandler(savedPost, error)
            }
        }
    }
    
    func getPostById(_ postId: String, completionHandler: @escaping (Post?, AnyObject?) -> ()) -> () {
        var avedPost: Post?
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["post"].arrayValue.count > 0 {
                    avedPost = Post(jsonObject: jsonObject["post"].arrayValue.first!)
                }
                /*let postJson = result!["post"] as? [[String: AnyObject]]
                let post = Post(jsonObject: postJson![0] as! JSON) */
                completionHandler(avedPost, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        
    }
    
    func filterPost(_ topics: [Topic]?, types: [PostType]?, fromDate: Date?, toDate: Date?, userId: Int?, quantity: Int?, page: Int?, podId: Int?, filterByUserInterests: Bool, sort_by: String?, completionHandler: @escaping ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        if topics != nil {
            let topicsNameArray = topics?.map({ $0.name })
            
            var topics: [String] = []
            for item in topicsNameArray! {
                topics.append(item!)
            }
            
            filters["topics"]   = topics as AnyObject?
            print(topics)
        }
        if types != nil {
            let typesNameArray = types?.map({ $0.name })
            filters["types"]   = typesNameArray as? [String] as AnyObject?
            print(typesNameArray!)
        }
        if fromDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: fromDate!)
            filters["from_date"]     = dateString as AnyObject?
        }
        if toDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: toDate!)
            filters["to_date"]       = dateString as AnyObject?
        }
        if userId != nil {
            filters["user_id"] = userId as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        if podId != nil {
            filters["pod_id"] = podId as AnyObject?
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by as AnyObject?
        }

        if filterByUserInterests && currentUser != nil {
            if let grades = currentUser!.grades {
                if grades.count > 0 {
                    let gradesArray   = grades.map({ $0.id! })
                    filters["grades"] = gradesArray as AnyObject?
                }
            }
            if let subjects = currentUser!.subjects {
                if subjects.count > 0 {
                    let subjectsArray   = subjects.map({ $0.id! })
                    filters["subjects"] = subjectsArray as AnyObject?
                }
            }
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let postJsonArray = jsonObject["posts"].arrayValue
                if postJsonArray.count > 0 {
                    for elem in postJsonArray {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }

    func filterPost(_ topics: [Topic]?, types: [PostType]?, fromDate: Date?, toDate: Date?, userId: Int?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: @escaping ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        if topics != nil {
            let topicsNameArray = topics?.map({ $0.name })
            filters["topics"]   = topicsNameArray as? [String] as AnyObject?
            print(topicsNameArray!)
        }
        if types != nil {
            let typesNameArray = types?.map({ $0.name })
            filters["types"]   = typesNameArray as? [String] as AnyObject?
            print(typesNameArray!)
        }
        if fromDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: fromDate!)
            filters["from_date"]     = dateString as AnyObject?
        }
        if toDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: toDate!)
            filters["to_date"]       = dateString as AnyObject?
        }
        if userId != nil {
            filters["user_id"] = userId as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by as AnyObject?
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let postJsonArray = jsonObject["posts"].arrayValue
                if postJsonArray.count > 0 {
                    for elem in postJsonArray {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }
    
    func filterMyFeedsPost(_ quantity: Int?, page: Int?, completionHandler: @escaping ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        filters["grades"] = self.currentUser?.getGradeIds() as AnyObject?
        filters["subjects"]   = self.currentUser?.getSubjectIds() as AnyObject?
        
        print(self.currentUser?.getGradeIds() as Any)
        print(self.currentUser?.getSubjectIds() as Any)
        
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let postJsonArray = jsonObject["posts"].arrayValue
                if postJsonArray.count > 0 {
                    for elem in postJsonArray {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }
    
    func getPostComments(_ postId: String, completionHandler: @escaping ([PostComment], AnyObject?) -> ()) -> () {
        var postComments: [PostComment] = []
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostComments, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let postCommentsJsonArray = jsonObject["comments"].array
                for elem in postCommentsJsonArray! {
                    postComments.append(PostComment(jsonObject: elem))
                }
                completionHandler(postComments, nil)
            } else {
                completionHandler(postComments, error)
            }
        }
    }
    
    func getPostLikes(_ postId: String, completionHandler: @escaping ([Like], AnyObject?) -> ()) -> () {
        var postLikes: [Like] = []
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let postLikesJsonArray = jsonObject["likes"].array
                for elem in postLikesJsonArray! {
                    postLikes.append(Like(jsonObject: elem))
                }
                completionHandler(postLikes, nil)
            } else {
                completionHandler(postLikes, error)
            }
        }
    }
    
    func deletePost(_ postId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PostById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    func reportPost(_ postId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.POST, authenticated: true, method: .PostReport, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    // MARK: - TOPICS
    
    func createTopic(_ topic: Topic, completionHandler: @escaping (Topic?, AnyObject?) -> ()) -> () {
        var savedTopic: Topic?
        let parameters : [String : AnyObject]? = ["topic": topic.toJson() as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .CreateTopic, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["topic"].arrayValue.count > 0 {
                    savedTopic = Topic(jsonObject: jsonObject["topic"].arrayValue.first!)
                }
                /*if let topicJson = result!["topic"] as? [[String: AnyObject]] {
                    savedTopic = Topic(jsonObject: topicJson[0] as JSON)
                } */
                completionHandler(savedTopic, nil)
            } else {
                completionHandler(savedTopic, error)
            }
        }
    }
    
    func deleteTopic(_ topicId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [topicId]
        performRequest(MethodType.DELETE, authenticated: true, method: .TopicById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    func getTopicByUser(_ userId: String, completionHandler: @escaping ([Topic], AnyObject?) -> ()) -> () {
        var topics: [Topic] = []
        let urlParameters : [CVarArg] = [userId]

        performRequest(MethodType.GET, authenticated: true, method: .TopicByUser, urlParams: urlParameters, params: nil, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let podsJsonArray = jsonObject["topics"].array
                if podsJsonArray?.count > 0 {
                    for elem in podsJsonArray! {
                        topics.append(Topic(jsonObject: elem))
                    }
                }
                completionHandler(topics, nil)
            } else {
                completionHandler(topics, error)
            }
        }
    }
    
    func filterTopic(_ pattern: String?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: @escaping ([Topic], AnyObject?) -> ()) -> () {
        var topics: [Topic] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by as AnyObject?
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterTopic, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let topicJsonArray = jsonObject["topics"].array
                if topicJsonArray?.count > 0 {
                    for elem in topicJsonArray! {
                        topics.append(Topic(jsonObject: elem))
                    }
                }
                completionHandler(topics, nil)
            } else {
                completionHandler(topics, error)
            }
        }
    }
    
    // MARK: - Notifications.
    func filterNotification(_ pattern: String?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: @escaping ([Notification], AnyObject?) -> ()) -> () {
        var notifications: [Notification] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by as AnyObject?
        }
        
        filters["user_id"] = self.currentUserId as AnyObject?
        //filters["user_id"] = 276 as AnyObject?
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterNotification, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let json = JSON(result!)
                let notificationJsonArray = json["notifications"].arrayValue
                if notificationJsonArray.count > 0 {
                    for elem in notificationJsonArray {
                        notifications.append(Notification(jsonObject: elem[0] as JSON))
                        //notifications.append((elem.first as AnyObject) as! Notification)
                    }
                }
                completionHandler(notifications, nil)
            } else {
                completionHandler(notifications, error)
            }
        }
    }

    // MARK: - Shares
    func createPostShare(_ postId: String, type: Int, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [postId]
        let parameters : [String : AnyObject]? = ["type": type as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .PostShare, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    //MARK: - Opens
    func createPostOpen(_ postId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [postId]
        let parameters : [String : AnyObject]? = ["like": "" as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .PostOpen, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }

    
    // MARK: - LIKES
    
    func createLike(_ postId: String, completionHandler: @escaping (Like?, AnyObject?) -> ()) -> () {
        var savedLike: Like?
        let urlParameters : [CVarArg] = [postId]
        let parameters : [String : AnyObject]? = ["like": "" as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["like"].arrayValue.count > 0 {
                    savedLike = Like(jsonObject: jsonObject["like"].arrayValue.first!)
                }
                /*if let likeJson = result!["like"] as? [[String: AnyObject]] {
                    savedLike = Like(jsonObject: likeJson[0] as AnyObject)
                } */
                completionHandler(savedLike, nil)
            } else {
                completionHandler(savedLike, error)
            }
        }
        
    }
    
    func deleteLike(_ postId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [postId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }
    
    // MARK: - PODS
    
    func createPOD(_ pod: POD, completionHandler: @escaping (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["pod": pod.toJson() as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .CreatePOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let podJson = result!["pod"] {
                    savedPOD = POD(jsonObject: podJson as! JSON)
                }
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
    }
    
    func updateInfoPOD(_ pod: PODRequest, completionHandler: @escaping (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["pod": pod.toJson() as AnyObject]
        performRequest(MethodType.PATCH, authenticated: true, method: .CreatePOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let podJson = result!["pod"] {
                    savedPOD = POD(jsonObject: podJson as! JSON)
                }
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
    }
    
    func likeComment(_ commentId: String,podId: String, completionHandler: @escaping (Bool?, AnyObject?) -> ()) -> () {
        //var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["like": "{}" as AnyObject]
        let urlParameters : [CVarArg] = [podId, commentId]
        print(parameters!)
        performRequest(MethodType.POST, authenticated: true, method: .LikeComment, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                completionHandler(true, nil)
                /*if let likeJson = result!["like"] as? [String: AnyObject] {
                    savedPOD = POD(jsonObject: likeJson)
                    completionHandler(true, nil)
                }*/
                
            } else {
                
                completionHandler(false, error)
            }
        }
    }
    
    func dislikeComment(_ commentId: String,podId: String, completionHandler: @escaping (Bool?, AnyObject?) -> ()) -> () {
        //var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["like": "{}" as AnyObject]
        let urlParameters : [CVarArg] = [podId, commentId]
        print(parameters!)
        performRequest(MethodType.DELETE, authenticated: true, method: .LikeComment, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                completionHandler(true, nil)
                /*if let likeJson = result!["like"] as? [String: AnyObject] {
                    savedPOD = POD(jsonObject: likeJson)
                    completionHandler(true, nil)
                }*/
                
            } else {
                
                completionHandler(false, error)
            }
        }
    }
    
    
    func updatePod(_ jsonParamter: NSDictionary, completionHandler: @escaping (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["pod": jsonParamter]
        print(parameters!)
        performRequest(MethodType.PATCH, authenticated: true, method: .CreatePOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                //if let podJson = jsonObject["pod"] {
                    savedPOD = POD(jsonObject: jsonObject["pod"])
                //}
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
    }
    
    func getPOD(_ podId: Int, completionHandler: @escaping (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let urlParameters : [CVarArg] = [String(podId)]
        performRequest(MethodType.GET, authenticated: true, method: .PODById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                //if let podJson = jsonObject["pod"] {
                    savedPOD = POD(jsonObject: jsonObject["pod"])
                //}
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
        
    }
    
    func filterPOD(_ pattern: String?, userId: Int?, fromDate: Date?, toDate: Date?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: @escaping ([POD], AnyObject?) -> ()) -> () {
        var pods: [POD] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern as AnyObject?
        }
        if userId != nil {
            filters["user_id"] = userId as AnyObject?
        }
        if fromDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: fromDate!)
            filters["from_date"]     = dateString as AnyObject?
        }
        if toDate != nil {
            let dateFormatter        = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.string(from: toDate!)
            filters["to_date"]       = dateString as AnyObject?
        }
        if quantity != nil {
            filters["quantity"] = quantity as AnyObject?
        }
        if page != nil {
            filters["page"] = page as AnyObject?
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by as AnyObject?
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                let podsJsonArray = jsonObject["pods"].arrayValue
                if podsJsonArray.count > 0 {
                    for elem in podsJsonArray {
                        pods.append(POD(jsonObject: elem))
                    }
                }
                completionHandler(pods, nil)
            } else {
                completionHandler(pods, error)
            }
        }
    }
    
    func getPodById(_ podId: String, completionHandler: @escaping (POD?, AnyObject?) -> ()) -> () {
       let urlParameters : [CVarArg] = [podId]
        performRequest(MethodType.GET, authenticated: true, method: .PODById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                print(jsonObject)
                let podJson = jsonObject["pod"]
                let pod = POD(jsonObject: podJson)
                completionHandler(pod, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func deletePOD(_ podId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [podId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PODById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }
    func deletePodMember(_ podId: String, userId: String,completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [podId, userId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PodMember, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    func joinPodMember(_ podId: String, completionHandler: @escaping (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArg] = [podId]
        performRequest(MethodType.POST, authenticated: true, method: .JoinInPod, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            print(result!)
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }

    // MARK: - COMMENTS
    
    func createComment(_ postId: String, postComment: PostComment, completionHandler: @escaping (PostComment?, AnyObject?) -> ()) -> () {
        var savedPostComment: PostComment?
        let urlParameters : [CVarArg] = [postId]
        let parameters : [String : AnyObject]? = ["comment": postComment.toJson() as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .PostComments, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["comment"].arrayValue.count > 0 {
                    savedPostComment = PostComment(jsonObject: jsonObject["comment"].arrayValue.first!)
                }
                /*if let postJson = result!["comment"] as? [[String: AnyObject]] {
                    savedPostComment = PostComment(jsonObject: postJson[0] as AnyObject)
                } */
                completionHandler(savedPostComment, nil)
            } else {
                completionHandler(savedPostComment, error)
            }
        }
    }
    
    func createCommentUpdate(_ postId: Int, postComment: PostCommentRequest, completionHandler: @escaping (PostComment?, AnyObject?) -> ()) -> () {
        var savedPostComment: PostComment?
        let urlParameters : [CVarArg] = [String(postId)]
        let parameters : [String : AnyObject]? = ["comment": postComment.toJson() as AnyObject]
        performRequest(MethodType.POST, authenticated: true, method: .PostComments, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let jsonObject = JSON(result!)
                if jsonObject["comment"].arrayValue.count > 0 {
                    savedPostComment = PostComment(jsonObject: jsonObject["comment"].arrayValue.first!)
                }
                /*if let postJson = result!["comment"] as? [[String: AnyObject]] {
                    savedPostComment = PostComment(jsonObject: postJson[0] as AnyObject)
                } */
                completionHandler(savedPostComment, nil)
            } else {
                completionHandler(savedPostComment, error)
            }
        }
    }
    
    
    // MARK: - Internal Methods
    
    /**
    Prepare the URL for an invocation to the API
    
    :param: method        Specific method that will be executed
    :param: urlParams     Group of params to add in the URL
    
    :returns: Returns the complete URL for the invocation
    */
    fileprivate func prepareRequestURL(_ method: ApiMethod, urlParams: [CVarArg]?) -> String? {
        if urlParams != nil {
            return String(format: basePath + method.rawValue, arguments: urlParams!)
        } else {
            return basePath + method.rawValue
        }
    }
    
    /**
     Uses Alamofire to make an HTTP Request
     
     :param: type              Method for the HTTP Request.
     :param: authenticated     Indicates if the URL will contain sph and key
     :param: method            Path for the specific method that is called
     :param: urlParams         Group of params to add in the URL
     :param: params            Parameters for the Request
     :param: completionHandler Block that will be executed when the invocation is done
    */
    func performRequest(_ type: MethodType, authenticated: Bool, method: ApiMethod, urlParams: [CVarArg]?, params: [String: AnyObject]?, jsonEconding: Bool, completionHandler: @escaping (AnyObject?, AnyObject?) -> ()) -> () {
        
        let urlString: String? = prepareRequestURL(method, urlParams: urlParams)
        
        var requestMethod: HTTPMethod!
        switch type {
        case MethodType.POST:
            requestMethod = .post
        case MethodType.GET:
            requestMethod = .get
        case MethodType.PUT:
            requestMethod = .put
        case MethodType.DELETE:
            requestMethod = .delete
        case MethodType.PATCH:
            requestMethod = .patch
        }
        
        var headers: [String: String]?
        if authenticated {
            headers = ["X-Authorization": self.token!]
        } else {
            headers = nil
        }
        
        let encoding: ParameterEncoding = jsonEconding ? JSONEncoding.default : URLEncoding.default
        //let encoding: ParameterEncoding = jsonEconding ? .json : .url
        
        Alamofire.request(urlString!, method: requestMethod, parameters: params, encoding: encoding, headers: headers).responseJSON(completionHandler: { (response: DataResponse<Any>) in
            
            //print(response.request!)  // original URL request
            //print(response.response!) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                if jsonData["errors"] != JSON.null {
                    completionHandler(nil, data as AnyObject?)
                } else {
                    completionHandler(data as AnyObject?, nil)
                }
                
                break
            case .failure(_):
                let dic = ["errors": [String(response.result.error!.localizedDescription)]]
                completionHandler(nil, dic as AnyObject?)

                break
            }
            
            /*var errorJson: AnyObject? = nil
            do {
                errorJson = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as AnyObject?
            } catch {
                print("error serializing Error JSON: \(error)")
            }
            
            if response.result.error == nil {
                if let resultValue = response.result.value {
                    let jsonData = JSON(resultValue)
                    if jsonData["error"] != JSON.null {
                        completionHandler(nil, resultValue as AnyObject?)
                    } else {
                        completionHandler(resultValue as AnyObject?, nil)
                    }
                } else {
                    completionHandler(nil, errorJson)
                }
            } else {
                if errorJson == nil {
                    let dic = ["errors": [String(response.result.error!.localizedDescription)]]
                    completionHandler(nil, dic as AnyObject?)
                } else {
                    completionHandler(nil, errorJson)
                }
            } */
        })
        
        /*Alamofire.request(requestMethod, urlString!, parameters: params, encoding: encoding, headers: headers)
            .validate()
            .responseJSON { response in
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                var errorJson: AnyObject? = nil
                do {
                    errorJson = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                } catch {
                    print("error serializing Error JSON: \(error)")
                }
                
                if response.result.error == nil {
                    if let JSON = response.result.value {
                        completionHandler(JSON, nil)
                    } else {
                        completionHandler(nil, errorJson)
                    }
                } else {
                    if errorJson == nil {
                        let dic = ["errors": [String(response.result.error!.localizedDescription)]]
                        completionHandler(nil, dic)
                    } else {
                        completionHandler(nil, errorJson)
                    }
                }
            }.validate() */
    }
    
}
