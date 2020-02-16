//
//  ChallengesViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The main view controller you see in  the Challenges tab in the app.
class ChallengesViewController: UITableViewController, UserTracking {
    var coordinator: ChallengesCoordinator?

    /// This handles all the rows in our table view.
    var dataSource = ChallengesDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Challenges"
        registerForUserChanges()

        tableView.dataSource = dataSource
        tableView.register(ChallengeTableViewCell.self, forCellReuseIdentifier: "Challenge")
        tableView.register(PreviousChallengeTableViewCell.self, forCellReuseIdentifier: "PreviousChallenge")
        extendedLayoutIncludesOpaqueBars = true

        NotificationCenter.default.addObserver(self, selector: #selector(userDataChanged), name: UIApplication.willEnterForegroundNotification, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // reload our table each time the user returns here so that daily challenge updates correctly
        tableView.reloadData()
        coordinator?.resetDetailViewController()

    }

    func userDataChanged() {
        tableView.reloadData()
    }

    /// This either starts today's challenge (if they haven't done it already), or shares their score.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if !User.current.hasCompletedTodaysChallenge {
                coordinator?.startChallenge()
            }
        } else {
            guard User.current.dailyChallenges.count > 0 else { return }
            let sourceRect = tableView.rectForRow(at: indexPath)
            coordinator?.shareScore(User.current.dailyChallenges[indexPath.row], from: sourceRect)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
