
//  AppDelegate.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import OAuthSwift
import SVProgressHUD
import FBSDKCoreKit
import PinterestSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    var window: UIWindow?
    var homeViewController: UIViewController!
    var navigationController: UINavigationController!
    
    var apiToken: String = ""
    var currentUserId: Int?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self, Twitter.self])
        
        PDKClient.configureSharedInstance(withAppId: "4849615424301575636")

        //Enable Push notification.
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        // Set appearance of Navigation and Status bars
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().barTintColor = UIColor.blueDolphin()
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().backgroundColor = UIColor.blueDolphin()
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: Constants.Fonts.Raleway_Bold, size: 16)!]
        
        // Set appearance for SVProgressHud
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setForegroundColor(UIColor.blueDolphin())
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        homeViewController = HomeViewController()
        
        let loginVC = LoginViewController()
        var userLogged: Bool
        // Access to the token to see if I'm logged
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "api_token") {
            print("Api Token = \(token)")
            apiToken = token
            userLogged = true
        } else {
            userLogged = false
        }
        if let userId = defaults.string(forKey: "current_user_id") {
            print("Current User Id = \(userId)")
            currentUserId = Int(userId)
        }
        
        //User.
        if let userData = defaults.object(forKey: "current_user") {
            let json = Globals.nsdataToJSON(userData as! Data)
            let user = User(jsonObject: json!)
            networkController.currentUser = user
        }
        
        networkController.currentUserId = currentUserId
        networkController.token         = apiToken
        
        if userLogged == true {
            navigationController       = UINavigationController(rootViewController: homeViewController)
            navigationController.isNavigationBarHidden = false
        }
        else {
            navigationController       = UINavigationController(rootViewController: loginVC)
            navigationController.isNavigationBarHidden = true
        }
        
        
        // Initialize root controller with sidebar
        let rearViewController = SidebarViewController(homeVC: homeViewController as! HomeViewController)
        let revealController = SWRevealViewController(rearViewController: rearViewController, frontViewController: navigationController)
        
        
        window!.rootViewController = revealController
        window!.makeKeyAndVisible()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return PDKClient.sharedInstance().handleCallbackURL(url)
    }
    
    // MARK: FacebookSDK
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        PDKClient.sharedInstance().handleCallbackURL(url)
        
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        } else if (url.scheme == "dolphin-app") {
            if let params = url.queryItems {
                if let postId = params["post_id"] {
                    print("Post Id is \(postId)")
                }
            }
        } else {
            if url.absoluteString.hasPrefix("fb") {
                return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let characterSet: CharacterSet = CharacterSet(charactersIn: "<>")
        let deviceTokenString: String = (deviceToken.description as NSString)
            .trimmingCharacters(in: characterSet)
            .replacingOccurrences( of: " ", with: "") as String
        Globals.currentDeviceToken = deviceTokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Recived: \(userInfo)")
        //Parsing userinfo:
        
        if let post_id = userInfo["post_id"] as? Int {
            networkController.getPostById("\(post_id)", completionHandler: { (post, error) in
                if error == nil {
                    let postDetailsVC = PostDetailsViewController()
                    postDetailsVC.post = post
                    self.navigationController.pushViewController(postDetailsVC, animated: true)
                }
                else {
                    
                }
            })
        }
        else if let pod_id = userInfo["pod_id"] as? Int {
            networkController.getPodById("\(pod_id)", completionHandler: { (pod, error) in
                if error == nil {
                    let podDetailsVC = PODDetailsViewController()
                    podDetailsVC.pod = pod
                    self.navigationController.pushViewController(podDetailsVC, animated: true)
                }
                else {
                    
                }
            })
        }
    }
}

