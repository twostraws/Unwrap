//
//  HomeDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the items in the Home table view. This is a fairly grim class and really ought to be refactored.
class HomeDataSource: NSObject, UICollectionViewDataSource {
    /// An array of all badges the user can earn.
    let badges = Bundle.main.decode([Badge].self, from: "Badges.json")

    // We have five sections: the status view, points, stats, streak, and badges.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            return badges.count

        default:
            fatalError("Unknown collection view section: \(section).")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.item == 0 {
                return makeStatus(in: collectionView, indexPath: indexPath)
            } else {
                return makePointsSummary(in: collectionView, indexPath: indexPath)
            }

        case 1:
            return makePointsBreakdown(in: collectionView, indexPath: indexPath)

        case 2:
            return makeStatistic(in: collectionView, indexPath: indexPath)

        case 3:
            return makeStreak(in: collectionView, indexPath: indexPath)

        case 4:
            return makeBadge(in: collectionView, indexPath: indexPath)

        default:
            fatalError("Unknown index path: \(indexPath).")
        }
    }

//    // All sections have a title except the first one.
//    func collectionView(_ collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return nil
//
//        case 1:
//            return "POINTS"
//
//        case 2:
//            return "STATS"
//
//        case 3:
//            return "STREAK"
//
//        case 4:
//            return "BADGES"
//
//        default:
//            fatalError("Unknown table view section: \(section).")
//        }
//    }

    /// Shows the activity ring and current rank.
    func makeStatus(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Rank", for: indexPath) as? StatusCollectionViewCell else {
            fatalError("Failed to dequeue a StatusCollectionViewCell.")
        }

        cell.statusView.shadowOpacity = 0
        cell.statusView.strokeColorStart = UIColor(bundleName: "Rank-Start")
        cell.statusView.strokeColorEnd = UIColor(bundleName: "Rank-End")

        return cell
    }

    /// Shows the user's total points in large text.
    func makePointsSummary(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Points", for: indexPath) as? PointsCollectionViewCell else {
            fatalError("Failed to dequeue a PointsCollectionViewCell.")
        }
        
        let totalPoints = User.current.totalPoints
        cell.textLabel.attributedText = NSAttributedString.makeTitle("Points", subtitle: totalPoints.formatted)
        cell.accessibilityLabel = "\(totalPoints) points"

        return cell
    }

    /// Shows the user's points breakdown.
    func makePointsBreakdown(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueStatReusableCell(in: collectionView, indexPath: indexPath)

        switch indexPath.item {
        case 0:
//            cell.textLabel?.text = "Learning Points"
//            cell.detailTextLabel?.text = User.current.learnPoints.formatted
            cell.accessibilityLabel = "\(User.current.learnPoints) points from learning"

        case 1:
//            cell.textLabel?.text = "Review Points"
//            cell.detailTextLabel?.text = User.current.reviewPoints.formatted
            cell.accessibilityLabel = "\(User.current.reviewPoints) points from reviews"

        case 2:
//            cell.textLabel?.text = "Practice Points"
//            cell.detailTextLabel?.text = User.current.practicePoints.formatted
            cell.accessibilityLabel = "\(User.current.practicePoints) points from practicing"

        case 3:
//            cell.textLabel?.text = "Challenge Points"
//            cell.detailTextLabel?.text = User.current.challengePoints.formatted
            cell.accessibilityLabel = "\(User.current.challengePoints) points from challenges"

        case 4:
//            cell.textLabel?.text = "Share Score"
            cell.accessibilityTraits = .button
//            cell.textLabel?.textColor = UIColor(bundleName: "Primary")

        default:
            fatalError("Unknown index path: \(indexPath).")
        }

        return cell
    }

    /// Shows how the user is progressing through levels.
    func makeStatistic(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueStatReusableCell(in: collectionView, indexPath: indexPath)

        switch indexPath.item {
        case 0:
//            cell.textLabel?.text = "Current Level"
//            cell.detailTextLabel?.text = "\(User.current.rankNumber)/21"
            cell.accessibilityLabel = "You are level \(User.current.rankNumber) of 21."

        case 1:
//            cell.textLabel?.text = "Points Until Next Level"

            if let points = User.current.pointsUntilNextRank {
//                cell.detailTextLabel?.text = String(points)
                cell.accessibilityLabel = "You need \(points) more points to reach the next level."
            } else {
//                cell.detailTextLabel?.text = "N/A"
                cell.accessibilityLabel = "You are at the maximum level."
            }

        case 2:
//            cell.textLabel?.text = "Daily Challenges"
//            cell.detailTextLabel?.text = String(User.current.dailyChallenges.count)
            cell.accessibilityLabel = "\(User.current.dailyChallenges) daily challenges completed."

        default:
            fatalError("Unknown index path: \(indexPath).")
        }

        return cell
    }

    /// Shows the user's streak record.
    func makeStreak(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueStatReusableCell(in: collectionView, indexPath: indexPath)
        switch indexPath.item {
        case 0:
//            cell.textLabel?.text = "Current Streak"
//            cell.detailTextLabel?.text = "\(User.current.streakDays)"
            cell.accessibilityLabel = "Your streak count is \(User.current.streakDays)"
            // UITest reading accessibility label and not accessibility identifier in Storyboard
            cell.accessibilityIdentifier = "Streak Reminder"
            return cell

        case 1:
//            cell.textLabel?.text = "Best Streak"
//            cell.detailTextLabel?.text = "\(User.current.bestStreak)"
            cell.accessibilityLabel = "Your best streak count is \(User.current.bestStreak)"
            // UITest reading accessibility label and not accessibility identifier in Storyboard
            cell.accessibilityIdentifier = "Streak Reminder"
            return cell

        default:
            fatalError("Unknown index path: \(indexPath).")
        }
    }

    /// Dequeue a reusable and clean collection view cell to show an stat.
    func dequeueStatReusableCell(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Stat", for: indexPath)
//        cell.textLabel?.textColor = nil
//        cell.detailTextLabel?.text = nil
        cell.accessibilityLabel = nil
        cell.accessibilityTraits = .none

        return cell
    }

    /// Shows all the badges the user has earned.
    func makeBadge(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Badge", for: indexPath) as? BadgeCollectionViewCell else {
            fatalError("Failed to dequeue a BadgeCollectionViewCell.")
        }

        let badge = badges[indexPath.item]
        cell.imageView.image = badge.image
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "Badge" + badge.name

        /// Highlight earned badges in whatever color was specified in the JSON. Also configures the accessibility values.
        if User.current.isBadgeEarned(badge) {
            cell.imageView.tintColor = UIColor(bundleName: badge.color)
            cell.accessibilityTraits = .button
            cell.accessibilityValue = "Earned"
            cell.accessibilityHint = "Share Badge"
        } else {
            cell.imageView.tintColor = UIColor(bundleName: "Locked")
            cell.accessibilityTraits = .none
            cell.accessibilityValue = User.current.badgeProgress(badge).string
        }

        return cell
    }
}
