//
//  HomeViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import StoreKit
import UIKit

/// The main view controller you see in  the Home tab in the app.
class HomeViewController: UITableViewController, Storyboarded, UserTracking {
    var coordinator: HomeCoordinator?
    var dataSource = HomeDataSource()
    var reviewRequested = false

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Home"
        registerForUserChanges()
        tableView.dataSource = dataSource

        let helpButton = UIBarButtonItem(title: "Help", style: .plain, target: coordinator, action: #selector(HomeCoordinator.showHelp))
        navigationItem.rightBarButtonItem = helpButton
    }

    /// When running on a real device for a user that has been using the app for a while, this prompts for a review.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        #if DEBUG
            // showing the review request thing while debugging is annoying, so we'll just do nothing instead
        #else
            // once the user has had some time with the app, ask them what they think
            if reviewRequested == false && User.current.totalPoints > 2000 {
                SKStoreReviewController.requestReview()
                reviewRequested = true
            }
        #endif

        // Attempt to alleviate the performance freeze when loading our collection view.
        preheatBadges()
    }

    /// This briefly touches the images for our badges, which helps scrolling performance when users see the collection view for the first time. Even though this won't cause the images to be fully loaded, it still about halves the overall rendering time.
    func preheatBadges() {
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")

        for badge in badges {
            _ = badge.image
        }
    }

    /// Calculate the height for table section headers; the first section shouldn't have a title.
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            // Using 0 for a section height doesn't work, so this value is effectively 0.
            return CGFloat.leastNonzeroMagnitude
        } else {
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            /// See the comment for BadgeTableViewCell.applyLayoutWorkaround()
            return 550
        } else {
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            /// See the comment for BadgeTableViewCell.applyLayoutWorkaround()
            return 550
        } else {
            return UITableView.automaticDimension
        }
    }

    /// See the comment for BadgeTableViewCell.applyLayoutWorkaround()
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if let cell = cell as? BadgeTableViewCell {
                cell.applyLayoutWorkaround()
            }
        }
    }

    /// When the Share Score cell is tapped start the share score process, otherwise do nothing.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shareScorePath = IndexPath(row: 4, section: 1)

        if indexPath == shareScorePath {
            let rect = tableView.rectForRow(at: indexPath)
            coordinator?.shareScore(from: rect)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    /// Refreshes everything when the user changes.
    func userDataChanged() {
        tableView.reloadData()
    }
}
