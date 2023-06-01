//
//  AppDelegate.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/08.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

import AdFooter
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Playlist.load()
        buildAppearance()

        #if targetEnvironment(simulator)
            prepareForSimulator()
        #endif

        buildWindow()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func prepareForSimulator() {
        Playlist.all.forEach { $0.destroy() }

        Playlist.create(name: "English 2: have")
        Playlist.create(name: "English 1: be")

        let playlist = Playlist.all[0]
        playlist.appendTracks([
            Track(title: "1. Exercise 1: I have a pen.",
                  assetURL: Bundle.main.url(forResource: "track1", withExtension: "m4a")!),
            Track(title: "2. Exercise 2: They each have an apple.",
                  assetURL: Bundle.main.url(forResource: "track2", withExtension: "m4a")!),
            Track(title: "3. Exercise 3: Have a nice day.",
                  assetURL: Bundle.main.url(forResource: "track3", withExtension: "m4a")!)
        ])

        Settings.reset()
    }

    func buildAppearance() {
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).barTintColor = Color.primary
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).tintColor = Color.white
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).titleTextAttributes = [
            .foregroundColor: Color.white
        ]

        if #available(iOS 15.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = Color.primary
            navAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
                .standardAppearance = navAppearance
            UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
                .scrollEdgeAppearance = navAppearance
        }
    }

    func buildWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)

        let rootViewController = PlaylistsViewController()
        let navController = NavigationController(rootViewController: rootViewController)

        #if DEBUG
            let hiddenAd = true
        #else
            let hiddenAd = false
        #endif

        AdFooter.shared.adMobApplicationId = ABFlowKeys().adMobApplicationId
        AdFooter.shared.adMobAdUnitId = ABFlowKeys().adMobAdUnitId
        AdFooter.shared.hidden = hiddenAd
        let adController = AdFooter.shared.wrap(navController)
        adController.view.backgroundColor = Color.darkGray
        window?.rootViewController = adController

        window?.makeKeyAndVisible()
    }
}
