//
//  AppDelegate.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import UIKit
import CoreData
import WatchKitCoreDataFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        print(NSHomeDirectory())

        dataController = AppGroupDataController() {
            [unowned self] () -> Void in

            // Prevent standing up the UI when being launched in the background
            if (application.applicationState != .Background) {
                self.setupUI()
            }
        }

        return true
    }

    /// Called after state restoration
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    /// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    /// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    func applicationWillResignActive(application: UIApplication) {
        saveData()
    }

    /// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    /// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(application: UIApplication) {
        saveData()
    }

    /// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(application: UIApplication) {
        // If launched in the background, but then transitioning into the foreground, we need to stand up the UI
        if window == nil {
            setupUI()
        }
    }

    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(application: UIApplication) { }

    /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /// Saves changes in the application's managed object context before the application terminates.
    func applicationWillTerminate(application: UIApplication) {
        saveData()
    }

    // MARK: - Private

    /// Tells the dataController to save.
    private func saveData () {
        dataController?.save()
    }

    /// Stands up the initial UI of the app.
    private func setupUI() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {

            let window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window.rootViewController = vc
            window.makeKeyAndVisible()
            self.window = window

            // Pass the data controller down through the UI
            if let dc = vc as? DataConsumer {
                dc.dataController = dataController
            }
        }
    }

}

