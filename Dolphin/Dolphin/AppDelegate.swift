//
//  AppDelegate.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var homeViewController: UIViewController!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])

        NetworkController.sharedInstance.initializeNetworkController()
        
        // Set appearance of Navigation and Status bars
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().barTintColor = UIColor.blueDolphin()
        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        
        homeViewController = HomeViewController()
        
        let loginVC = LoginViewController()
        let initialViewController = UINavigationController(rootViewController: loginVC)
        
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


}

