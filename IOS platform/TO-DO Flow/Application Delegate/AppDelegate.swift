//
//  AppDelegate.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/17/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coreDataManager = CoreDataManager(modelName: "Tasks")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = window?.rootViewController as? TabbarController
        var allTabs = tabBarController?.viewControllers
        
        // Navigation Controller in the first tab
        let navigationController = allTabs?[0] as? UINavigationController
        let tasksVC = navigationController?.topViewController as? TasksVC
        tasksVC?.managedObjectContext = coreDataManager.managedObjectContext
        loadData()
        
        let navigationController1 = allTabs?[1] as? UINavigationController
        let _ = navigationController1?.topViewController as? CalendarVC
        
        let _ = allTabs?[2] as? SettingTableVC
        
        return true
    }
    
    private func loadData() {
        
        let defaults = UserDefaults.standard
        
        let isLoaded = defaults.bool(forKey: "isLoaded")
        
        if !isLoaded {
            print("loading")
            
            
            // Category
            let grocery = Category(context: coreDataManager.managedObjectContext)
            grocery.name = "grocery"
            
            // Tag
            let red = Tag(context: coreDataManager.managedObjectContext)
            red.name = "red"
            red.colorName = "red"
            let green = Tag(context: coreDataManager.managedObjectContext)
            green.name = "green" 
            green.colorName = "green"
            
            let brown = Tag(context: coreDataManager.managedObjectContext)
            brown.colorName = "brown"
            let cyan = Tag(context: coreDataManager.managedObjectContext)
            cyan.colorName = "cyan"
            let magenta = Tag(context: coreDataManager.managedObjectContext)
            magenta.colorName = "magenta"
            let orange = Tag(context: coreDataManager.managedObjectContext)
            orange.colorName = "orange"
            let purple = Tag(context: coreDataManager.managedObjectContext)
            purple.colorName = "purple"
            let yellow = Tag(context: coreDataManager.managedObjectContext)
            yellow.colorName = "yellow"
            
            do {
                try coreDataManager.managedObjectContext.save()
            }
            catch {
                fatalError("Can't save data")
            }
            
            defaults.set(true, forKey: "isLoaded")
        }
        else {
            print("Data was loaded before!")
        }
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

