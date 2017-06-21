//
//  AppDelegate.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/21.
//  Copyright © 2017年 WHY. All rights reserved.
//

import UIKit
import ChameleonFramework
import RESideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .default
        UINavigationBar.appearance().tintColor = FlatBlack()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        UIBarButtonItem.appearance().tintColor = UIColor.init(contrastingBlackOrWhiteColorOn: FlatBlack(), isFlat: true)
        UINavigationBar.appearance().tintColor = UIColor.init(contrastingBlackOrWhiteColorOn: FlatBlack(), isFlat: true)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = FlatBlack()
        
        let navigationController = UINavigationController.init(rootViewController: HomeViewController())
        
        let leftVC = LeftMenuViewController()
        let sideMenuViewController = RESideMenu.init(contentViewController: navigationController, leftMenuViewController: leftVC, rightMenuViewController: nil)
        sideMenuViewController?.view.backgroundColor = FlatBlack()
        sideMenuViewController?.menuPreferredStatusBarStyle = UIStatusBarStyle(rawValue: 1)!
        sideMenuViewController?.contentViewShadowColor = FlatWhite()
        sideMenuViewController?.contentViewShadowOffset = CGSize(width: 0, height: 0)
        sideMenuViewController?.contentViewShadowOpacity = 0.6
        sideMenuViewController?.contentViewShadowRadius = 4
        sideMenuViewController?.contentViewShadowEnabled = true
        sideMenuViewController?.delegate = self
        
        window?.rootViewController = sideMenuViewController
        
        
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


}

extension AppDelegate: RESideMenuDelegate {
    
    func sideMenu(_ sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func sideMenu(_ sideMenu: RESideMenu!, willHideMenuViewController menuViewController: UIViewController!) {
        UIApplication.shared.statusBarStyle = .default
    }
}
