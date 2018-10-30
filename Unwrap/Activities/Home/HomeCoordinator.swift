//
//  HomeCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import SafariServices
import UIKit

/// Manages everything launched from the Home tab in the app.
class HomeCoordinator: Coordinator, AlertShowing {
    var navigationController: CoordinatedNavigationController

    private static let firstRunDefaultsKey = "ShownFirstRun"

    /// True when this is the first time the app has been launched.
    var isFirstRun: Bool {
        return UserDefaults.standard.bool(forKey: HomeCoordinator.firstRunDefaultsKey) == false
    }

    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.coordinator = self

        let viewController = HomeViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(bundleName: "Home"), tag: 0)
        viewController.coordinator = self

        navigationController.viewControllers = [viewController]

        if isFirstRun {
            /// If this is the first time the app is running, wait a tiny fraction of time before showing the welcome screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Put the contents of showTour in here directly avoid trying to capture `self` during an initializer.
                let viewController = WelcomeViewController.instantiate()
                viewController.presentAsAlert()

                // Mark that we've run the app at least once.
                UserDefaults.standard.set(true, forKey: HomeCoordinator.firstRunDefaultsKey)
            }
        }
    }

    /// Show the welcome screen with a short app introduction.
    func showTour() {
        let viewController = WelcomeViewController.instantiate()
        viewController.presentAsAlert()
    }

    /// Show the help screen.
    @objc func showHelp() {
        let viewController = HelpViewController.instantiate()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    /// Start sharing the user's current score.
    func shareScore() {
        let image = User.current.rankImage.imageForSharing
        let text = "I'm on level \(User.current.rankNumber) in Unwrap. Download it here: \(Unwrap.appURL)"

        let alert = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
        alert.completionWithItemsHandler = handleScoreSharingResult
        navigationController.present(alert, animated: true)
    }

    /// Start sharing the a specific badge the user earned, or just show information about it if the badge is not currently earned.
    func shareBadge(_ badge: Badge) {
        if User.current.isBadgeEarned(badge) {
            // This badge is earned, so share it using the system share sheet.
            showAlert(title: badge.name, body: badge.description, alternateTitle: "Share") {
                let image = badge.image
                let text = "I earned the badge \(badge.name) in Unwrap. Download it here: \(Unwrap.appURL)"

                let alert = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
                self.navigationController.present(alert, animated: true)
            }
        } else {
            // This badge isn't earned; just show details about it.
            let alert = AlertViewController.instantiate()
            alert.title = badge.name
            alert.body = badge.description.fromSimpleHTML()
            alert.presentAsAlert()
        }
    }

    /// We need to catch them sharing their score successfully, because doing it at least once to Facebook or Twitter unlocks a badge.
    func handleScoreSharingResult(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        guard completed == true else { return }

        if activityType == .postToFacebook || activityType == .postToTwitter {
            User.current.sharedScore()
        }
    }

    /// HTTP(S) URLs should be opened internally, but all others – e.g. mailto: – should be opened by the system.
    func open(_ url: URL) {
        if url.scheme?.hasPrefix("http") == true {
            // we'll open web URLs inside the app
            let viewController = SFSafariViewController(url: url)
            navigationController.present(viewController, animated: true)
        } else {
            // send all other types of URL over to the main application to figure out
            UIApplication.shared.open(url)
        }
    }

    /// Show credits for the app.
    @objc func showCredits() {
        let credits = CreditsViewController.instantiate()
        navigationController.pushViewController(credits, animated: true)
    }
}
