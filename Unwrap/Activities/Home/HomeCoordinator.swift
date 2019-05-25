//
//  HomeCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages everything launched from the Home tab in the app.
class HomeCoordinator: Coordinator, AlertShowing {
    var splitViewController = PortraitSplitViewController()
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
        let viewController = HelpViewController(style: .plain)
        viewController.coordinator = self

        if UIDevice.current.userInterfaceIdiom == .pad {
            let navController = CoordinatedNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .formSheet
            navigationController.present(navController, animated: true)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    /// Start sharing the user's current score.
    func shareScore(from sourceRect: CGRect) {
        let image = User.current.rankImage.imageForSharing
        let text = "I'm on level \(User.current.rankNumber) in Unwrap by @twostraws. Download it here: \(Unwrap.appURL)"

        let alert = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
        alert.completionWithItemsHandler = handleScoreSharingResult

        // if we're on iPad there is nowhere sensible to anchor this from, so just center it
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = navigationController.topViewController?.view
            popOver.sourceRect = sourceRect
        }

        navigationController.present(alert, animated: true)
    }

    /// Show a dialog with the badge's description. If the badge has been earned then the dialog has an option to share otherwise the progress is presented.
    func showBadgeDetails(_ badge: Badge) {
        if User.current.isBadgeEarned(badge) {
            let body = badge.description.fromSimpleHTML()
            showAlert(title: badge.name, body: body, alternateTitle: "Share") { [weak self] in
                self?.shareBadge(badge)
            }
        } else {
            let body = badge.description.centered() + User.current.badgeProgress(badge)
            showAlert(title: badge.name, body: body)
        }
    }

    /// Share a specific badge the user earned.
    func shareBadge(_ badge: Badge) {
        let image = badge.image.imageForSharing
        let text = "I earned the badge \(badge.name) in Unwrap by @twostraws. Download it here: \(Unwrap.appURL)"

        let alert = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)

        // if we're on iPad there is nowhere sensible to anchor this from, so just center it
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = self.navigationController.view
            popOver.sourceRect = CGRect(x: self.navigationController.view.frame.midX, y: self.navigationController.view.frame.midY, width: 0, height: 0)
        }

        self.navigationController.present(alert, animated: true)
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
            let viewController = WebViewController(url: url)
            navigationController.pushViewController(viewController, animated: true)
        } else {
            // send all other types of URL over to the main application to figure out
            UIApplication.shared.open(url)
        }
    }
}
