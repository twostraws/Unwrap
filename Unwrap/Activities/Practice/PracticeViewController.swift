//
//  PracticeViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The main view controller you see in  the Practice tab in the app.
class PracticeViewController: UITableViewController, Storyboarded, UserTracking {
    var coordinator: PracticeCoordinator?

    /// This handles all the rows in our table view.
    var dataSource = PracticeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Practice"
        registerForUserChanges()
        tableView.dataSource = dataSource
    }

    /// Refreshes everything when the user changes.
    func userDataChanged() {
        tableView.reloadData()
    }

    /// When the user selects a practice activity, pull it out from our data source and ask the coordinator to kick it off.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = dataSource.activity(at: indexPath.row)

        if coordinator?.startPracticing(activity) == false {
            // failed to start practicing - probably locked
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
