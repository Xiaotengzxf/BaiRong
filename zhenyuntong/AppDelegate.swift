//
//  AppDelegate.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/3.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import CocoaAsyncSocket

//var sqlManager : SQLiteManager?
var MODELITEM = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {

    var window: UIWindow?
    //var clientSocket : GCDAsyncSocket?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 23/255.0, green: 130/255.0, blue: 210/255.0, alpha: 1)], for: .selected)
        application.setStatusBarStyle(.lightContent, animated: false)
        IQKeyboardManager.sharedManager().enable = true
        
        checkIsLogin()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func checkIsLogin() {
        if let _ = UserDefaults.standard.object(forKey: "mine") {
            
        }else{
            setRootControllerWithLogin()
        }
    }
    
    func setRootControllerWithLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "navigation") as? UINavigationController {
            self.window?.rootViewController = controller
        }
    }
}

