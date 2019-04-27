//
//  ChallengesDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Practice table view.
class ChallengesDataSource: NSObject, UITableViewDataSource {
    // This has two sections: an option to start today's challenge or a reminder that they already took today's challenge, plus a history of their previous challenge attempts.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Today's challenge"
        } else {
            return "Previous challenges"
        }
    }

    // This tells users that tapping the date of a previous challenge will share it, because it's not obvious.
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && User.current.dailyChallenges.count > 0 {
            return "Tap any date to share your score."
        }

        return nil
    }

    // Always show one row in the first section ("Take today's challenge" or "You already took today's challenge"), then show as many rows as needed in the second section in order to handle all previous challenge results.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return max(User.current.dailyChallenges.count, 1)
        }
    }

    /// Configures cells either to show information on today's challenge, or to show historical scores.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if User.current.hasCompletedTodaysChallenge {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Challenge", for: indexPath)
                cell.accessoryType = .none
                cell.selectionStyle = .none
                cell.textLabel?.text = "Come Back Tomorrow"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Challenge", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = Date().formatted
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousChallenge", for: indexPath)

            if User.current.dailyChallenges.isEmpty {
                cell.textLabel?.text = "No completed challenges yet"
                cell.detailTextLabel?.text = nil
                cell.selectionStyle = .none
            } else {
                let challenge = User.current.dailyChallenges[indexPath.row]
                cell.textLabel?.text = "\(challenge.date.formatted)"
                cell.detailTextLabel?.text = "Score: \(challenge.score)"
                cell.selectionStyle = .default
            }

            return cell
        }
    }
}
