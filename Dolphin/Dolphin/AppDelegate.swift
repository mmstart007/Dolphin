
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    var window: UIWindow?
    var homeViewController: UIViewController!
    var apiToken: String = ""
    var currentUserId: Int?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self, Twitter.self])
        
        
        // Set appearance of Navigation and Status bars
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().barTintColor = UIColor.blueDolphin()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        UINavigationBar.appearance().backgroundColor = UIColor.blueDolphin()
        UINavigationBar.appearance().shadowImage = UIImage()
        
        // Set appearance for SVProgressHud
        
        SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
        SVProgressHUD.setForegroundColor(UIColor.blueDolphin())
        SVProgressHUD.setDefaultMaskType(.Clear)
        
        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        
        homeViewController = HomeViewController()
        
        let loginVC = LoginViewController()
        var userLogged: Bool
        // Access to the token to see if I'm logged
        let defaults = NSUserDefaults.standardUserDefaults()
        if let token = defaults.stringForKey("api_token") {
            print("Api Token = \(token)")
            apiToken = token
            userLogged = true
        } else {
            userLogged = false
        }
        if let userId = defaults.stringForKey("current_user_id") {
            print("Current User Id = \(userId)")
            currentUserId = Int(userId)
        }
        
        //User.
        if let userData = defaults.objectForKey("current_user") {
            let json = Globals.nsdataToJSON(userData as! NSData)
            let user = User(jsonObject: json!)
            networkController.currentUser = user
        }
        
        networkController.currentUserId = currentUserId
        networkController.token         = apiToken
        let rootViewController          = userLogged ? homeViewController : loginVC
        let initialViewController       = UINavigationController(rootViewController: rootViewController)
        
        // Initialize root controller with sidebar
        let rearViewController = SidebarViewController(homeVC: homeViewController as! HomeViewController)
        let revealController = SWRevealViewController(rearViewController: rearViewController, frontViewController: initialViewController)
        
        
        window!.rootViewController = revealController
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: FacebookSDK
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        } else if (url.scheme == "dolphin-app") {
            if let params = url.queryItems {
                if let postId = params["post_id"] {
                    print("Post Id is \(postId)")
                }
            }
        } else {
            if url.absoluteString.hasPrefix("fb") {
                return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            }
        }
        return true
    }
    
    
    
    
}

