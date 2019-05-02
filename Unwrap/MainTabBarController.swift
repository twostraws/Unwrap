//
//  MainTabBarController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A UITabBarController subclass that sets up our main coordinators as each of the five app tabs.
class MainTabBarController: UITabBarController, Storyboarded {
    let home = HomeCoordinator()
    let learn = LearnCoordinator()
    let practice = PracticeCoordinator()
    let challenges = ChallengesCoordinator()
    let news = NewsCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [home.navigationController, learn.splitViewController, practice.splitViewController, challenges.splitViewController, news.splitViewController]
        tabBar.isTranslucent = false
    }

    /// If we get some launch options, figure out which one was requested and jump right to the correct tab.
    func handle(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handle(shortcutItem: item)
        }
    }

    func handle(shortcutItem: UIApplicationShortcutItem) {
        if shortcutItem.type == "com.hackingwithswift.unwrapswift.challenges" {
            selectedViewController = challenges.splitViewController
        } else if shortcutItem.type == "com.hackingwithswift.unwrapswift.news" {
            selectedViewController = news.splitViewController
        } else {
            fatalError("Unknown shortcut item type: \(shortcutItem.type).")
        }
    }
}
