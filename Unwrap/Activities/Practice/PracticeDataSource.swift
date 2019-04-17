//
//  PracticeDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Practice table view.
class PracticeDataSource: NSObject, UITableViewDataSource {
    /// The complete list of practice activities we want to show to users.
    var activities: [PracticeActivity.Type] = [ReviewPractice.self, FreeCodingPractice.self, PredictTheOutputPractice.self, RearrangeTheLinesPractice.self, SpotTheErrorPractice.self, TapToCodePractice.self, TypeCheckerPractice.self]

    override init() {
        // sort the activities by title; will be useful when translations are added
        activities.sort {
            $0.name < $1.name
        }
    }

    /// Sends back a specific activity using its integer position.
    func activity(at index: Int) -> PracticeActivity.Type {
        return activities[index]
    }

    /// Allocate one row per activity.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    /// Configures each cell either using a lock symbol and unlock instructions (for locked activities), or the activity's icon and description (for unlocked activities).
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.name

        if activity.isLocked {
            cell.detailTextLabel?.text = "Complete \"\(activity.lockedUntil)\" to unlock."
            cell.imageView?.image = UIImage(bundleName: "Lock")
            cell.imageView?.tintColor = UIColor(bundleName: "Locked")
            cell.accessoryType = .none
        } else {
            cell.detailTextLabel?.text = activity.subtitle
            cell.imageView?.image = activity.icon
            cell.imageView?.tintColor = nil
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }
}
