//
//  NetworkController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/22/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import Alamofire

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
        case GetSubjects        = "subjects"
        case GetGrades          = "grades"
        case CreatePost         = "posts"
        case FilterPost         = "posts/filter"
        case PostById           = "posts/%@"
        case PostComments       = "posts/%@/comments"
        case PostLikes          = "posts/%@/likes"
        case PostReport         = "posts/%@/reports"
        case CreateTopic        = "topics"
        case TopicById          = "topics/%@"
        case TopicByUser        = "topics/user/%@"
        case FilterTopic        = "topics/filter"
        
        case CreatePOD          = "pods"
        case FilterPOD          = "pods/filter"
        case PODById            = "pods/%@"
        case PodMember          = "pods/%@/users/%@"
    }
    
    
    // MARK: - Public Methods
    // MARK: - USERS
    
    func login(userName: String, password: String, completionHandler: (User?, String?, Int?, AnyObject?) -> ()) -> () {
        var retToken: String?
        var retUserId: Int?
        var loginParams = ["username": userName, "password": password]
        if Globals.currentDeviceToken.characters.count > 0 {
            loginParams["device_token"] = Globals.currentDeviceToken
        }
        
        let parameters : [String : AnyObject]? = ["login": loginParams]
        performRequest(MethodType.POST, authenticated: true, method: .Login, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                retToken = result!["token"] as? String
                let retUser = result!["user"] as? [String: AnyObject]
                retUserId = retUser!["id"] as? Int
                self.token = retToken
                self.currentUserId = retUserId
                self.currentUser = User(jsonObject: retUser!)
                completionHandler(self.currentUser, retToken, retUserId, nil)
            } else {
                completionHandler(self.currentUser, retToken, retUserId, error)
            }
        }
        
    }
    
    func registerUser(user: User, completionHandler: (User?, String?, Int?, AnyObject?) -> ()) -> () {
        var retToken: String?
        var retUserId: Int?
        var userInfo = user.toJson()
        
        if Globals.currentDeviceToken.characters.count > 0 {
            userInfo["device_token"] = Globals.currentDeviceToken
        }
        
        let parameters = ["user": userInfo]
        performRequest(MethodType.POST, authenticated: false, method: .User, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                retToken = (result!["api_token"] as? String)!
                let retUser = result!["user"] as? [String: AnyObject]
                retUserId = retUser!["id"] as? Int
                self.token = retToken
                self.currentUserId = retUserId
                self.currentUser = User(jsonObject: retUser!)
                completionHandler(self.currentUser, retToken, retUserId, nil)
            } else {
                completionHandler(nil, retToken, retUserId, error)
            }
        }
    }
    
    func updateUser(userName: String?, deviceId: String?, firstName: String?, lastName: String?, avatarImage: String?, email: String?, password: String?, location: String?, isPrivate: Int?, subjects: [String]?, grades: [String]?, completionHandler: (User?, AnyObject?) -> ()) -> () {
        
        var userUpdated: User?
        var updateValues = [String: AnyObject]()
        if userName != nil {
            updateValues["username"] = userName
        }
        if deviceId != nil {
            updateValues["device_id"] = deviceId
        }
        if firstName != nil {
            updateValues["first_name"] = firstName
        }
        if lastName != nil {
            updateValues["last_name"] = lastName
        }
        if avatarImage != nil {
            updateValues["avatar_image"] = avatarImage
        }
        if email != nil {
            updateValues["email"] = email
        }
        if password != nil {
            updateValues["password"] = password
        }
        if location != nil {
            updateValues["location"] = location
        }
        if isPrivate != nil {
            updateValues["is_private"] = isPrivate!
        }
        if grades != nil {
            updateValues["grades"] = grades
        }
        if subjects != nil {
            updateValues["subjects"] = subjects
        }
        let parameters : [String : AnyObject]? = ["user": updateValues]
        performRequest(MethodType.PATCH, authenticated: true, method: .User, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let userRet = result!["user"] as? [String: AnyObject] {
                    userUpdated = User(jsonObject: userRet)
                }
                completionHandler(userUpdated, nil)
            } else {
                completionHandler(userUpdated, error)
            }
        }
    }
    
    func filterUser(pattern: String?, podId: Int?, fromDate: NSDate?, toDate: NSDate?, quantity: Int?, page: Int?, completionHandler: ([User], AnyObject?) -> ()) -> () {
        var users: [User] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern
        }
        if podId != nil {
            filters["pod_id"] = podId
        }
        if fromDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(fromDate!)
            filters["from_date"]     = dateString
        }
        if toDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(toDate!)
            filters["to_date"]       = dateString
        }
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterUser, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let usersJsonArray = result!["users"] as? [AnyObject]
                if usersJsonArray?.count > 0 {
                    for elem in usersJsonArray! {
                        users.append(User(jsonObject: elem))
                    }
                }
                completionHandler(users, nil)
            } else {
                completionHandler(users, error)
            }
        }
    }
    
    func getUserById(userId: String, completionHandler: (User?, AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let userJson = result!["user"] as? [String: AnyObject]
                let user = User(jsonObject: userJson!)
                completionHandler(user, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        
    }
    
    func getUserLikes(userId: String, completionHandler: ([Like], AnyObject?) -> ()) -> () {
        var userLikes: [Like] = []
        let urlParameters : [CVarArgType] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let userLikesJsonArray = result!["likes"] as? [AnyObject]
                for elem in userLikesJsonArray! {
                    userLikes.append(Like(jsonObject: elem))
                }
                completionHandler(userLikes, nil)
            } else {
                completionHandler(userLikes, error)
            }
        }
        
    }
    
    func getUserLikePost(userId: String, postId: String, completionHandler: (Bool, AnyObject?) -> ()) -> () {
        var userLikePost: Bool = false
        let urlParameters : [CVarArgType] = [userId, postId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserLikePost, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let userLikeJsonArray = result!["likes"] as? [[String: AnyObject]]
                let userLikeJson = userLikeJsonArray![0]
                userLikePost = userLikeJson["id"] != nil
                completionHandler(userLikePost, nil)
            } else {
                completionHandler(userLikePost, error)
            }
        }
        
    }
    
    
    func getUserComments(userId: String, completionHandler: ([PostComment], AnyObject?) -> ()) -> () {
        var userComments: [PostComment] = []
        let urlParameters : [CVarArgType] = [userId]
        performRequest(MethodType.GET, authenticated: true, method: .GetUserComments, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let userCommentsJsonArray = result!["comments"] as? [AnyObject]
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
    func getSubjects(completionHandler: ([Subject]?, AnyObject?) -> ()) -> () {
        var subjects: [Subject] = []
        performRequest(MethodType.GET, authenticated: true, method: .GetSubjects, urlParams: nil, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let arraySubjects = result as? [AnyObject]
                for elem in arraySubjects! {
                    subjects.append(Subject(jsonObject: elem))
                }
                completionHandler(subjects, nil)
            } else {
                completionHandler(subjects, error)
            }
        }
    }
    
    func getGrades(completionHandler: ([Grade]?, AnyObject?) -> ()) -> () {
        var grades: [Grade ] = []
        performRequest(MethodType.GET, authenticated: true, method: .GetGrades, urlParams: nil, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let arraySubjects = result as? [AnyObject]
                for elem in arraySubjects! {
                    grades.append(Grade(jsonObject: elem))
                }
                completionHandler(grades, nil)
            } else {
                completionHandler(grades, error)
            }
        }
    }
    
    func updateGradesAndSubjects(grades: [String]?, subjects: [String]?, completionHandler: (User?, AnyObject?) -> ()) -> () {
        var user = [String: AnyObject]()
        user["grades"] = grades
        user["subjects"] = subjects

        let parameters : [String : AnyObject]? = ["user": user]
        performRequest(MethodType.PATCH, authenticated: true, method: .User, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let retUser = result!["user"] as? [String: AnyObject]
                self.currentUser = User(jsonObject: retUser!)
                completionHandler(self.currentUser, nil)
            } else {
                completionHandler(self.currentUser, error)
            }
        }
    }
    
    // MARK: - POSTS
    
    func createPost(post: Post, completionHandler: (Post?, AnyObject?) -> ()) -> () {
        var savedPost: Post?
        let parameters : [String : AnyObject]? = ["post": post.toJson()]
        performRequest(MethodType.POST, authenticated: true, method: .CreatePost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let postJson = result!["post"] as? [[String: AnyObject]] {
                    savedPost = Post(jsonObject: postJson[0])
                }
                completionHandler(savedPost, nil)
            } else {
                completionHandler(savedPost, error)
            }
        }
    }
    
    func getPostById(postId: String, completionHandler: (Post?, AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let postJson = result!["post"] as? [[String: AnyObject]]
                let post = Post(jsonObject: postJson![0])
                completionHandler(post, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        
    }
    
    func filterPost(topics: [Topic]?, types: [PostType]?, fromDate: NSDate?, toDate: NSDate?, userId: Int?, quantity: Int?, page: Int?, podId: Int?, filterByUserInterests: Bool, sort_by: String?, completionHandler: ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        if topics != nil {
            let topicsNameArray = topics?.map({ $0.name })
            filters["topics"]   = topicsNameArray as? [String]
            print(topicsNameArray)
        }
        if types != nil {
            let typesNameArray = types?.map({ $0.name })
            filters["types"]   = typesNameArray as? [String]
            print(typesNameArray)
        }
        if fromDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(fromDate!)
            filters["from_date"]     = dateString
        }
        if toDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(toDate!)
            filters["to_date"]       = dateString
        }
        if userId != nil {
            filters["user_id"] = userId
        }
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        if podId != nil {
            filters["pod_id"] = podId
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by
        }

        if filterByUserInterests && currentUser != nil {
            if let grades = currentUser!.grades {
                if grades.count > 0 {
                    let gradesArray   = grades.map({ $0.id! })
                    filters["grades"] = gradesArray
                }
            }
            if let subjects = currentUser!.subjects {
                if subjects.count > 0 {
                    let subjectsArray   = subjects.map({ $0.id! })
                    filters["subjects"] = subjectsArray
                }
            }
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let postJsonArray = result!["posts"] as? [[AnyObject]]
                if postJsonArray?.count > 0 {
                    for elem in postJsonArray! {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }

    func filterPost(topics: [Topic]?, types: [PostType]?, fromDate: NSDate?, toDate: NSDate?, userId: Int?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        if topics != nil {
            let topicsNameArray = topics?.map({ $0.name })
            filters["topics"]   = topicsNameArray as? [String]
            print(topicsNameArray)
        }
        if types != nil {
            let typesNameArray = types?.map({ $0.name })
            filters["types"]   = typesNameArray as? [String]
            print(typesNameArray)
        }
        if fromDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(fromDate!)
            filters["from_date"]     = dateString
        }
        if toDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(toDate!)
            filters["to_date"]       = dateString
        }
        if userId != nil {
            filters["user_id"] = userId
        }
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let postJsonArray = result!["posts"] as? [[AnyObject]]
                if postJsonArray?.count > 0 {
                    for elem in postJsonArray! {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }
    
    func filterMyFeedsPost(quantity: Int?, page: Int?, completionHandler: ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        var filters = [String: AnyObject]()
        filters["grades"] = self.currentUser?.getGradeIds()
        filters["subjects"]   = self.currentUser?.getSubjectIds()
        
        print(self.currentUser?.getGradeIds())
        print(self.currentUser?.getSubjectIds())
        
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let postJsonArray = result!["posts"] as? [[AnyObject]]
                if postJsonArray?.count > 0 {
                    for elem in postJsonArray! {
                        posts.append(Post(jsonObject: elem[0]))
                    }
                }
                completionHandler(posts, nil)
            } else {
                completionHandler(posts, error)
            }
        }
    }

    
    func getPostComments(postId: String, completionHandler: ([PostComment], AnyObject?) -> ()) -> () {
        var postComments: [PostComment] = []
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostComments, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let postCommentsJsonArray = result!["comments"] as? [AnyObject]
                for elem in postCommentsJsonArray! {
                    postComments.append(PostComment(jsonObject: elem))
                }
                completionHandler(postComments, nil)
            } else {
                completionHandler(postComments, error)
            }
        }
        
    }
    
    
    func getPostLikes(postId: String, completionHandler: ([Like], AnyObject?) -> ()) -> () {
        var postLikes: [Like] = []
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.GET, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                let postLikesJsonArray = result!["likes"] as? [AnyObject]
                for elem in postLikesJsonArray! {
                    postLikes.append(Like(jsonObject: elem))
                }
                completionHandler(postLikes, nil)
            } else {
                completionHandler(postLikes, error)
            }
        }
        
    }
    
    func deletePost(postId: String, completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PostById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    func reportPost(postId: String, completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.POST, authenticated: true, method: .PostReport, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    // MARK: - TOPICS
    
    func createTopic(topic: Topic, completionHandler: (Topic?, AnyObject?) -> ()) -> () {
        var savedTopic: Topic?
        let parameters : [String : AnyObject]? = ["topic": topic.toJson()]
        performRequest(MethodType.POST, authenticated: true, method: .CreateTopic, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let topicJson = result!["topic"] as? [[String: AnyObject]] {
                    savedTopic = Topic(jsonObject: topicJson[0])
                }
                completionHandler(savedTopic, nil)
            } else {
                completionHandler(savedTopic, error)
            }
        }
        
    }
    
    func deleteTopic(topicId: String, completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [topicId]
        performRequest(MethodType.DELETE, authenticated: true, method: .TopicById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }
    
    func getTopicByUser(userId: String, completionHandler: ([Topic], AnyObject?) -> ()) -> () {
        var topics: [Topic] = []
        let urlParameters : [CVarArgType] = [userId]

        performRequest(MethodType.GET, authenticated: true, method: .TopicByUser, urlParams: urlParameters, params: nil, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let podsJsonArray = result!["topics"] as? [AnyObject]
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
    
    func filterTopic(pattern: String?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: ([Topic], AnyObject?) -> ()) -> () {
        var topics: [Topic] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern
        }
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterTopic, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let topicJsonArray = result!["topics"] as? [AnyObject]
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

    
    // MARK: - LIKES
    
    func createLike(postId: String, completionHandler: (Like?, AnyObject?) -> ()) -> () {
        var savedLike: Like?
        let urlParameters : [CVarArgType] = [postId]
        let parameters : [String : AnyObject]? = ["like": ""]
        performRequest(MethodType.POST, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let likeJson = result!["like"] as? [[String: AnyObject]] {
                    savedLike = Like(jsonObject: likeJson[0])
                }
                completionHandler(savedLike, nil)
            } else {
                completionHandler(savedLike, error)
            }
        }
        
    }
    
    func deleteLike(postId: String, completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [postId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PostLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }
    
    // MARK: - PODS
    
    func createPOD(pod: POD, completionHandler: (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["pod": pod.toJson()]
        performRequest(MethodType.POST, authenticated: true, method: .CreatePOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let podJson = result!["pod"] as? [String: AnyObject] {
                    savedPOD = POD(jsonObject: podJson)
                }
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
    }
    
    func updatePod(pod: POD, completionHandler: (POD?, AnyObject?) -> ()) -> () {
        var savedPOD: POD?
        let parameters : [String : AnyObject]? = ["pod": pod.toJson()]
        performRequest(MethodType.PATCH, authenticated: true, method: .CreatePOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let podJson = result!["pod"] as? [String: AnyObject] {
                    savedPOD = POD(jsonObject: podJson)
                }
                completionHandler(savedPOD, nil)
            } else {
                
                completionHandler(savedPOD, error)
            }
        }
    }
    
    func filterPOD(pattern: String?, userId: Int?, fromDate: NSDate?, toDate: NSDate?, quantity: Int?, page: Int?, sort_by: String?, completionHandler: ([POD], AnyObject?) -> ()) -> () {
        var pods: [POD] = []
        var filters = [String: AnyObject]()
        if pattern != nil {
            filters["pattern"] = pattern
        }
        if userId != nil {
            filters["user_id"] = userId
        }
        if fromDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(fromDate!)
            filters["from_date"]     = dateString
        }
        if toDate != nil {
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// date format "created_at": "2016-01-05 22:12:30"
            let dateString           = dateFormatter.stringFromDate(toDate!)
            filters["to_date"]       = dateString
        }
        if quantity != nil {
            filters["quantity"] = quantity
        }
        if page != nil {
            filters["page"] = page
        }
        if sort_by != nil {
            filters["sort_by"] = sort_by
        }
        
        let parameters : [String : AnyObject]? = ["filter": filters]
        performRequest(MethodType.POST, authenticated: true, method: .FilterPOD, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                let podsJsonArray = result!["pods"] as? [AnyObject]
                if podsJsonArray?.count > 0 {
                    for elem in podsJsonArray! {
                        pods.append(POD(jsonObject: elem))
                    }
                }
                completionHandler(pods, nil)
            } else {
                completionHandler(pods, error)
            }
        }
    }
    
    func deletePOD(podId: String, completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [podId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PODById, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }
    func deletePodMember(podId: String, userId: String,completionHandler: (AnyObject?) -> ()) -> () {
        let urlParameters : [CVarArgType] = [podId, userId]
        performRequest(MethodType.DELETE, authenticated: true, method: .PodMember, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
        
    }

    // MARK: - COMMENTS
    
    func createComment(postId: String, postComment: PostComment, completionHandler: (PostComment?, AnyObject?) -> ()) -> () {
        var savedPostComment: PostComment?
        let urlParameters : [CVarArgType] = [postId]
        let parameters : [String : AnyObject]? = ["comment": postComment.toJson()]
        performRequest(MethodType.POST, authenticated: true, method: .PostComments, urlParams: urlParameters, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                if let postJson = result!["comment"] as? [[String: AnyObject]] {
                    savedPostComment = PostComment(jsonObject: postJson[0])
                }
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
    private func prepareRequestURL(method: ApiMethod, urlParams: [CVarArgType]?) -> String? {
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
    func performRequest(type: MethodType, authenticated: Bool, method: ApiMethod, urlParams: [CVarArgType]?, params: [String: AnyObject]?, jsonEconding: Bool, completionHandler: (AnyObject?, AnyObject?) -> ()) -> () {
        let urlString: String? = prepareRequestURL(method, urlParams: urlParams)
        
        var requestMethod: Alamofire.Method
        switch type {
        case MethodType.POST:
            requestMethod = .POST
        case MethodType.GET:
            requestMethod = .GET
        case MethodType.PUT:
            requestMethod = .PUT
        case MethodType.DELETE:
            requestMethod = .DELETE
        case MethodType.PATCH:
            requestMethod = .PATCH
        }
        
        var headers: [String: String]?
        if authenticated {
            headers = ["X-Authorization": token!]
        } else {
            headers = nil
        }
        
        let encoding: ParameterEncoding = jsonEconding ? .JSON : .URL
        
        Alamofire.request(requestMethod, urlString!, parameters: params, encoding: encoding, headers: headers)
            .validate()
            .responseJSON { response in
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                var errorJson: AnyObject? = nil
                
                do {
                    errorJson = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments)
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
            }.validate()
        
    }
    
}
