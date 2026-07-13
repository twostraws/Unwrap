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
    }

    /// Selects the tab requested by a Home Screen quick action.
    @discardableResult
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        switch shortcutItem.type {
        case "com.hackingwithswift.unwrapswift.challenges":
            selectedViewController = challenges.splitViewController
            return true
        case "com.hackingwithswift.unwrapswift.news":
            selectedViewController = news.splitViewController
            return true
        default:
            return false
        }
    }
}
