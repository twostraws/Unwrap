//
//  AppDelegate.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import AVKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var tabBarController: MainTabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = .white

        // Instantiate UserDefaults keys to be monitored
        let defaults = UserDefaults()
        defaults.register(defaults: ["User": NSData(), "Test User": NSData(), "ZephyrSyncKey": String()])

        // Uncomment the following line to see Zephyr debug info in the console
        // Zephyr.debugEnabled = true

        // We're going to tell Zephyr which keys to monitor.
        Zephyr.addKeysToBeMonitored(keys: ["User", "Test User", "ZephyrSyncKey"])

        Zephyr.sync(keys: ["User", "Test User", "ZephyrSyncKey"])

        // Load the existing user if we already have one, or create a new one for the first run.
        User.current = User.load() ?? User()

        /// Send in the main tab bar controller, which can create our initial coordinators.
        tabBarController = MainTabBarController()
        window?.rootViewController = tabBarController

        /// We want the tab bar controller to handle our launch options so we can jump right too various tabs as needed.
        tabBarController?.handle(launchOptions)

        /// If a user has requested to play a movie, always play sound
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])

        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        tabBarController?.handle(shortcutItem: shortcutItem)
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }
}
