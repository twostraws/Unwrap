//
//  NewsCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SafariServices
import UIKit

/// Manages everything launched from the News tab in the app.
class NewsCoordinator: Coordinator {
    var navigationController: CoordinatedNavigationController

    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.coordinator = self

        let viewController = NewsViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "News", image: UIImage(bundleName: "News"), tag: 4)
        viewController.coordinator = self

        navigationController.viewControllers = [viewController]

        // force our view controller to load immediately, so we download the news in the background rather than waiting for users to go to the tab
        viewController.loadViewIfNeeded()
    }

    /// Creates and configures – but does not show! – a Safari view controller for a specific article. This might be called when the user tapped a story, or when they 3D touch one.
    func readViewController(for article: NewsArticle) -> UIViewController {
        let viewController = SFSafariViewController(url: article.url)
        return viewController
    }

    /// Triggered when we already have a Safari view controller configured and ready to go, so we just show it.
    func startReading(using viewController: UIViewController, withURL url: URL) {
        navigationController.present(viewController, animated: true)
        User.current.readNewsStory(forURL: url)
    }

    /// Creates, configures, and presents a Safari view controller for a specific article.
    func read(_ article: NewsArticle) {
        let viewController = readViewController(for: article)
        startReading(using: viewController, withURL: article.url)
    }

    /// Loads the Hacking with Swift store.
    @objc func buyBooks() {
        let storeURL = URL(staticString: "https://www.hackingwithswift.com/store")
        let viewController = SFSafariViewController(url: storeURL)
        navigationController.present(viewController, animated: true)
    }
}
