//
//  HomeDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Home table view. This is a fairly grim class and really ought to be refactored.
class HomeDataSource: NSObject, UITableViewDataSource {
    var badgeDataSource = BadgeDataSource()

    // We have five sections: the status view, points, stats, streak, and badges.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    // All sections have a title except the first one.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil

        case 1:
            return NSLocalizedString("POINTS", comment: "")

        case 2:
            return NSLocalizedString("STATS", comment: "")

        case 3:
            return NSLocalizedString("STREAK", comment: "")

        case 4:
            return NSLocalizedString("BADGES", comment: "")

        default:
            fatalError("Unknown table view section: \(section).")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // status view
            return 2

        case 1:
            // score breakdown
            return 5

        case 2:
            // level stats
            return 3

        case 3:
            // streak
            return 2

        case 4:
            // badges
            return 1

        default:
            fatalError("Unknown table view section: \(section).")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return makeStatus(in: tableView, indexPath: indexPath)
            } else {
                return makePointsSummary(in: tableView, indexPath: indexPath)
            }

        case 1:
            return makePointsBreakdown(in: tableView, indexPath: indexPath)

        case 2:
            return makeStatistic(in: tableView, indexPath: indexPath)

        case 3:
            return makeStreak(in: tableView, indexPath: indexPath)

        case 4:
            return makeBadges(in: tableView, indexPath: indexPath)

        default:
            fatalError("Unknown index path: \(indexPath).")
        }
    }

    /// Shows the activity ring and current rank.
    func makeStatus(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Rank", for: indexPath) as? StatusTableViewCell else {
            fatalError("Failed to dequeue a StatusTableViewCell.")
        }

        cell.statusView.shadowOpacity = 0
        cell.statusView.strokeColorStart = UIColor(bundleName: "Rank-Start")
        cell.statusView.strokeColorEnd = UIColor(bundleName: "Rank-End")

        return cell
    }

    /// Shows the user's total points in large text.
    func makePointsSummary(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Points", for: indexPath)
        cell.textLabel?.attributedText = NSAttributedString.makeTitle(NSLocalizedString("Points", comment: ""), subtitle: User.current.totalPoints.formatted)
        cell.accessibilityLabel = "\(User.current.totalPoints) points"

        return cell
    }

    /// Shows the user's points breakdown.
    func makePointsBreakdown(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueStatReusableCell(in: tableView, indexPath: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Learning Points", comment: "")
            cell.detailTextLabel?.text = User.current.learnPoints.formatted
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("%d points from learning", comment: ""), User.current.learnPoints)

        case 1:
            cell.textLabel?.text = NSLocalizedString("Review Points", comment: "")
            cell.detailTextLabel?.text = User.current.reviewPoints.formatted
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("%d points from reviews", comment: ""), User.current.reviewPoints)

        case 2:
            cell.textLabel?.text = NSLocalizedString("Practice Points", comment: "")
            cell.detailTextLabel?.text = User.current.practicePoints.formatted
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("%d points from practicing", comment: ""), User.current.practicePoints)

        case 3:
            cell.textLabel?.text = NSLocalizedString("Challenge Points", comment: "")
            cell.detailTextLabel?.text = User.current.challengePoints.formatted
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("%d points from challenges", comment: ""), User.current.challengePoints)

        case 4:
            cell.textLabel?.text = NSLocalizedString("Share Score", comment: "")
            cell.accessibilityTraits = .button
            cell.textLabel?.textColor = UIColor(bundleName: "Primary")

        default:
            fatalError("Unknown index path: \(indexPath).")
        }

        return cell
    }

    /// Shows how the user is progressing through levels.
    func makeStatistic(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueStatReusableCell(in: tableView, indexPath: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Current Level", comment: "")
            cell.detailTextLabel?.text = "\(User.current.rankNumber)/21"
            let levels = 21
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("You are on level %d of %d.", comment: ""), User.current.rankNumber, levels)

        case 1:
            cell.textLabel?.text = NSLocalizedString("Points Until Next Level", comment: "")

            if let points = User.current.pointsUntilNextRank {
                cell.detailTextLabel?.text = String(points)
                cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("You need %d more points to reach the next level.", comment: ""), points)
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("N/A", comment: "")
                cell.accessibilityLabel = NSLocalizedString("You are at the maximum level.", comment: "")
            }

        case 2:
            cell.textLabel?.text = NSLocalizedString("Daily Challenges", comment: "")
            cell.detailTextLabel?.text = String(User.current.dailyChallenges.count)
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("%d daily challenges completed.", comment: ""), User.current.dailyChallenges)

        default:
            fatalError("Unknown index path: \(indexPath).")
        }

        return cell
    }

    /// Shows the user's streak record.
    func makeStreak(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueStatReusableCell(in: tableView, indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Current Streak", comment: "")
            cell.detailTextLabel?.text = String(User.current.streakDays)
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("Your streak count is %d", comment: ""), User.current.streakDays)
            // UITest reading accessibility label and not accessibility identifier in Storyboard
            cell.accessibilityIdentifier = "Streak Reminder"
            return cell

        case 1:
            cell.textLabel?.text = NSLocalizedString("Best Streak", comment: "")
            cell.detailTextLabel?.text = "\(User.current.bestStreak)"
            cell.accessibilityLabel = .localizedStringWithFormat(NSLocalizedString("Your best streak count is %d", comment: ""), User.current.bestStreak)
            // UITest reading accessibility label and not accessibility identifier in Storyboard
            cell.accessibilityIdentifier = "Streak Reminder"
            return cell

        default:
            fatalError("Unknown index path: \(indexPath).")
        }
    }

    /// Dequeue a reusable and clean table view cell to show an stat.
    func dequeueStatReusableCell(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Stat", for: indexPath)
        cell.textLabel?.textColor = nil
        cell.detailTextLabel?.text = nil
        cell.accessibilityLabel = nil
        cell.accessibilityTraits = .none

        return cell
    }

    /// Shows all the badges the user has earned.
    func makeBadges(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Badges", for: indexPath) as? BadgeTableViewCell else {
            fatalError("Failed to dequeue a BadgeTableViewCell.")
        }

        cell.collectionView.dataSource = badgeDataSource
        cell.collectionView.delegate = badgeDataSource

        /// See the comment for BadgeTableViewCell.applyLayoutWorkaround()
        cell.layoutIfNeeded()

        return cell
    }
}
