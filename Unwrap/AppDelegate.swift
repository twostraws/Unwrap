//
//  AppDelegate.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import AVKit
import UIKit
import Zephyr

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Instantiate UserDefaults keys to be monitored
        let defaults = UserDefaults()
        defaults.register(defaults: ["User": NSData(), "Test User": NSData()])

        // Uncomment the following line to see Zephyr debug info in the console
        // Zephyr.debugEnabled = true

        // We're going to tell Zephyr which keys to monitor.
        Zephyr.addKeysToBeMonitored(keys: ["User", "Test User"])

        Zephyr.sync(keys: ["User", "Test User"])

        // Load the existing user if we already have one, or create a new one for the first run.
        User.current = User.load() ?? User()

        NotificationCenter.default.addObserver(self, selector: #selector(cloudDataChanged), name: Zephyr.keysDidChangeOnCloudNotification, object: nil)

        // If a user has requested to play a movie, always play sound
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])

        return true
    }

    @objc func cloudDataChanged() {
        User.current = User.load()
        User.current.cloudUpdate()
    }
}
