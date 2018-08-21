//
//  MainTabBarController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import UIKit

/// A UITabBarController subclass that sets up our main coordinators as each of the five app tabs.
class MainTabBarController: UITabBarController, UITabBarControllerDelegate, Storyboarded {
    let home = HomeCoordinator()
    let learn = LearnCoordinator()
    let practice = PracticeCoordinator()
    let challenges = ChallengesCoordinator()
    let news = NewsCoordinator()
    
    var previousViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        viewControllers = [home.navigationController, learn.navigationController, practice.navigationController, challenges.navigationController, news.navigationController]
        
        previousViewController = viewControllers?.first
    }

    /// If we get some launch options, figure out which one was requested and jump right to the correct tab.
    func handle(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            if shortcutItem.type == "com.hackingwithswift.unwrap.challenges" {
                selectedViewController = challenges.navigationController
            } else if shortcutItem.type == "com.hackingwithswift.unwrap.news" {
                selectedViewController = news.navigationController
            } else {
                fatalError("Unknown shortcut item type: \(shortcutItem.type).")
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController == previousViewController {
            if let scrollView = (viewController as? UINavigationController)?.viewControllers.first?.view as? UIScrollView {
                if !scrollView.scrolledToTop {
                    scrollView.scrollToTop()
                }
            }
        }
        
        previousViewController = viewController
        
    }
}
