//
//  AppDelegate.swift
//  SpotMap
//
//  Created by Владислав Пуличев on 17.01.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

//!!!DO NOT COMMIT THIS FILE!!!

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let appId = "4B2C12D1-C6DE-7B3E-FFF0-80E7D3628C00" //App Id uses to generate links to files. Dont forget it
    let secretKey = "A406030E-2CC8-5845-FF66-ADB6A424DB00"
    let versionNum = "v1"

    var backendless = Backendless.sharedInstance()

    var window: UIWindow?

    var storyboard: UIStoryboard?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // FireBase init part
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
        // Backendless init part
        backendless?.initApp(appId, secret:secretKey, version:versionNum)

        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Setting initial viewController for user loggedIn?
        if(backendless?.userService.currentUser != nil) {
            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginPage")
        }

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

    func applicationDidFinishLaunching(_ application: UIApplication) {

    }
}
