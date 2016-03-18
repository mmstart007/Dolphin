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
    
    var token: String      = ""
    var posts: [Post]      = []
    var likedPosts: [Post] = []
    var pods: [POD]        = []
    var deals: [Deal]      = []
    
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
    
    enum APIMethod: String {
        case GetTokenByDeviceId = "token/by-device-id/%@"
        case RegisterUser       = "users"
        case GetUserById        = "users/%@"
        case GetUserLikes       = "users/%@/likes"
        case CreatePost         = "posts"
        case GetUserComments    = "users/%@/comments"
        case GetAllPost         = "posts/filter"
        case PostById           = "posts/%@"
        case GetPostComments    = "posts/%@/comments"
        case GetPostLikes       = "posts/%@/likes"

    }
    
    
    // MARK: - Public Methods
    
    func getTokenByDeviceId(deviceId: String, completionHandler: (String, AnyObject?) -> ()) -> () {
        var token: String = ""
        let urlParameters : [CVarArgType] = [deviceId]
        performRequest(MethodType.GET, authenticated: true, method: .GetTokenByDeviceId, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
            if error == nil {
                token = (result!["token"] as? String)!
                completionHandler(token, nil)
            } else {
                completionHandler(token, error)
            }
        }
        
    }
    
    func registerUser(user: User, completionHandler: (String, AnyObject?) -> ()) -> () {
        var token: String = ""
        let parameters : [String : AnyObject]? = ["user": user.toJson()]
        performRequest(MethodType.POST, authenticated: false, method: .RegisterUser, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
            if error == nil {
                token = (result!["api_token"] as? String)!
                completionHandler(token, nil)
            } else {
                completionHandler(token, error)
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
    
    
    func getAllPost(completionHandler: ([Post], AnyObject?) -> ()) -> () {
        var posts: [Post] = []
        let parameters : [String : AnyObject]? = ["filter": ""]
        performRequest(MethodType.POST, authenticated: true, method: .GetAllPost, urlParams: nil, params: parameters, jsonEconding: true) { (result, error) -> () in
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
        performRequest(MethodType.GET, authenticated: true, method: .GetPostComments, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
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
        performRequest(MethodType.GET, authenticated: true, method: .GetPostLikes, urlParams: urlParameters, params: nil, jsonEconding: false) { (result, error) -> () in
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
    
    
    
    
    // MARK: - Internal
    
    /**
    Prepare the URL for an invocation to the API
    
    :param: method        Specific method that will be executed
    :param: urlParams     Group of params to add in the URL
    
    :returns: Returns the complete URL for the invocation
    */
    private func prepareRequestURL(method: APIMethod, urlParams: [CVarArgType]?) -> String? {
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
    func performRequest(type: MethodType, authenticated: Bool, method: APIMethod, urlParams: [CVarArgType]?, params: [String: AnyObject]?, jsonEconding: Bool, completionHandler: (AnyObject?, AnyObject?) -> ()) -> () {
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
            headers = ["X-Authorization": token]
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
                    
                    completionHandler(nil, errorJson)
                }
            }.validate()
        
    }
    
    
//    func initializeNetworkController() {
//        let user1 = User(deviceId: "", name: "John Doe", imageURL: "", email: "john@doe.com", password: "test")
//        
//        let comment1 = PostComment(user: user1, text: "Great stuff!", date: NSDate())
//        let comment2 = PostComment(user: user1, text: "I'll say!", date: NSDate())
//        let comment3 = PostComment(user: user1, text: "This is a larger comment than the previos one, I just want to test the cell height!", date: NSDate())
//        let comment4 = PostComment(user: user1, text: "This comment is even larger than the other one, and it is loooooooooooooooooooooooooooooooooooooooooooooooooooooong", date: NSDate())
//        let comment5 = PostComment(user: user1, text: "Great, the layout on the comments looks awesome!", date: NSDate())
//        
//        let post1 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: .URL, header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfLikes: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        let post2 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: false)
//        let post3 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of another awesome post!!!", date: NSDate(), numberOfLikes: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        posts = [post1, post2, post3]
//        
//        let post4 = Post(user: user1, imageURL: "https://anprak.files.wordpress.com/2014/01/thevergebanner.png?w=630&h=189", type: .URL, header: "https://www.theverge.com/", text: "This is an awesome site!", date: NSDate(), numberOfLikes: 1228, numberOfComments: 43, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        let post5 = Post(user: user1, imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRz1WiFnk8nU7JnT1KikESbt-SNIecF6GU1smWteRhyWWEaji9v", type: .Text, header: "", text: "This is the text of this awesome post!!!", date: NSDate(), numberOfLikes: 8, numberOfComments: 3, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        let post6 = Post(user: user1, imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRbUgMAg6ImQKs-nRmUnecDp_z-5SZjXbi2rxDot8LcV4eLQb8eIg", type: .Photo, header: "", text: "This is the text of another awesome post!!!", date: NSDate(), numberOfLikes: 1928, numberOfComments: 115, comments:[comment1, comment2, comment3, comment4, comment5], isLiked: true)
//        
//        likedPosts = [post4, post5, post6]
//        
//        let pod1 = POD(name: "Aviation", imageURL: "https://wallpaperscraft.com/image/plane_sky_flying_sunset_64663_3840x1200.jpg", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1, user1], isPrivate: true)
//        let pod2 = POD(name: "Engineering", imageURL: "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRcMgu3PJLY079zBrxFxZRDwl59nuVuluNdF6PtqJvIzoD39YCQKg", lastpostDate: NSDate(), users: [user1, user1, user1], isPrivate: false)
//        let pod3 = POD(name: "Electronics", imageURL: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUTqYPZGV5hcCSTuoRf_VR1lbN6lFZvGn8ufGPBNCEVRj7gdN3TA", lastpostDate: NSDate(), users: [user1, user1, user1, user1, user1], isPrivate: true)
//        
//        pods = [pod1, pod2, pod3]
//        
//        let deal1 = Deal(image: "http://www.freelogovectors.net/wp-content/uploads/2013/01/staples-logo.jpg", description: "50% STAPLES purchase of $100 or more", date: NSDate(), code: "http://freebarcodefonts.dobsonsw.com/images/code128bar.jpg")
//        let deal2 = Deal(image: "http://i.ebayimg.com/00/s/NzY4WDEwMjQ=/z/1I4AAOSwDNdVtpOh/$_3.jpg", description: "XBOX ONE (NIB)", date: NSDate(), code: "http://smallbiztrends.com/wp-content/uploads/2015/05/qr-code-sample.jpg")
//        let deal3 = Deal(image: "http://ecx.images-amazon.com/images/I/41aawS8-fLL._SY300_.jpg", description: "Ninja Turtles Remote Control Adapter", date: NSDate(), code: "")
//        
//        deals.append(deal1)
//        deals.append(deal2)
//        deals.append(deal3)
//    }
    
}
