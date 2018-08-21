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
    
    /// Scrolls to top of view when user taps on the current view controller's icon
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        defer {
            previousViewController = viewController
        }
        
        guard viewController == previousViewController else { return }
        
        guard let navigationController = viewController as? UINavigationController else { return }
        
        guard let scrollView = navigationController.viewControllers.first?.view as? UIScrollView else { return }
        
        if !scrollView.scrolledToTop {
            let navigationBarMaxHeight = navigationController.navigationBar.largeTitleHeight
            scrollView.scrollToTop(maxNavBarHeight: navigationBarMaxHeight)
        }
        
    }
}
