//
//  NewsCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages everything launched from the News tab in the app.
class NewsCoordinator: Coordinator {
    var splitViewController = PortraitSplitViewController()
    var primaryNavigationController = CoordinatedNavigationController()

    init() {
        // Set up the master view controller
        primaryNavigationController.navigationBar.prefersLargeTitles = true

        // FIXME: Disable translucency on this navigation bar, otherwise on iPad selecting a news story makes the navigation bar go gray.
        primaryNavigationController.navigationBar.isTranslucent = false
        primaryNavigationController.coordinator = self

        let viewController = NewsViewController(style: .plain)
        viewController.coordinator = self

        primaryNavigationController.viewControllers = [viewController]

        // force our view controller to load immediately, so we download the news in the background rather than waiting for users to go to the tab
        viewController.loadViewIfNeeded()

        // Set up the detail view controller
        let detailViewController = PleaseSelectViewController.instantiate()
        detailViewController.selectionMode = .news

        splitViewController.viewControllers = [primaryNavigationController, detailViewController]
        splitViewController.tabBarItem = UITabBarItem(title: "News", image: UIImage(bundleName: "News"), tag: 4)

        // make this split view controller behave sensibly on iPad
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = SplitViewControllerDelegate.shared
    }

    /// Creates and configures – but does not show! – an ArticleViewController for a specific article.
    /// This might be called when the user tapped a story, or when they 3D touch one.
    func articleViewController(for article: NewsArticle) -> UIViewController {
        let viewController = WebViewController(url: article.url)
        return viewController
    }

    /// Triggered when we already have a Safari view controller configured and ready to go, so we just show it.
    func startReading(using viewController: UIViewController, withURL url: URL) {
        let detailNav = CoordinatedNavigationController(rootViewController: viewController)
        splitViewController.showDetailViewController(detailNav, sender: self)
        User.current.readNewsStory(forURL: url)
    }

    /// Creates, configures, and presents an ArticleViewController for a specific article.
    func read(_ article: NewsArticle) {
        let viewController = articleViewController(for: article)
        startReading(using: viewController, withURL: article.url)
    }

    /// Loads the Hacking with Swift store.
    @objc func buyBooks() {
        let storeURL = URL(staticString: "https://www.hackingwithswift.com/store")
        let viewController = WebViewController(url: storeURL)
        let detailNav = CoordinatedNavigationController(rootViewController: viewController)
        splitViewController.showDetailViewController(detailNav, sender: self)
    }
}
