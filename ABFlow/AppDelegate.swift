//
//  AppDelegate.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/08.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Playlist.load()

        #if targetEnvironment(simulator)
            Playlist.all.forEach { $0.destroy() }

            Playlist.create(name: "English 2: have")
            Playlist.create(name: "English 1: be")

            let playlist = Playlist.all[0]
            playlist.appendTracks([
                Track(title: "1. Exercise 1: I have a pen.", assetURL: Bundle.main.url(forResource: "track1", withExtension: "m4a")!),
                Track(title: "2. Exercise 2: They each have an apple.", assetURL: Bundle.main.url(forResource: "track2", withExtension: "m4a")!),
                Track(title: "3. Exercise 3: Have a nice day.", assetURL: Bundle.main.url(forResource: "track3", withExtension: "m4a")!)
            ])

            Settings.reset()
        #endif

        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).barTintColor = Color.primary
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).tintColor = Color.white
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).titleTextAttributes = [
            .foregroundColor: Color.white
        ]

        window = UIWindow(frame: UIScreen.main.bounds)

        let rootViewController = PlaylistsViewController()
        let navController = NavigationController(rootViewController: rootViewController)
        window?.rootViewController = navController

        window?.makeKeyAndVisible()

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
