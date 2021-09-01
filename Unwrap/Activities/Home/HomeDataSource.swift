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
    // MARK: - Properties

    /// An array of all badges the user can earn.
    let badges = Bundle.main.decode([Badge].self, from: "Badges.json")
    private (set)var sections = [HomeSection]()

    // MARK: - Init

    override init() {
        super.init()

        sections = makeSections()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]

        switch section.type {
        case .status:
            switch item.type {
            case .status:
                return makeStatus(in: collectionView, indexPath: indexPath)

            case .summary:
                return makePointsSummary(in: collectionView, indexPath: indexPath)

            default:
                fatalError("Invalid item type: \(item.type).")
            }
        case .score, .stats, .streak:
            return makeStat(in: collectionView, indexPath: indexPath)

        case .badges:
            return makeBadge(in: collectionView, indexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return makeHeader(in: collectionView, indexPath: indexPath)
        default:
            fatalError("Unknown ElementOfKind: \(kind).")
        }
    }

    // MARK: - Methods

    private func makeSections() -> [HomeSection] {
        let status = HomeSection(title: nil, type: .status, items: [
            HomeItem(type: .status),
            HomeItem(type: .summary)
        ])

        let badges = HomeSection(
            title: "BADGES",
            type: .badges,
            items: Array(repeating: HomeItem(type: .badge), count: badges.count)
        )

        return [status, makeScoreSection(), makeStatsSection(), makeStreakSection(), badges]
    }

    private func makeScoreSection() -> HomeSection {
        let learningPoints = HomeItem(type: .stat(
            textLabel: "Learning Points",
            detailLabel: User.current.learnPoints.formatted,
            accessibilityLabel: "\(User.current.learnPoints) points from learning"
        ))

        let reviewPoints = HomeItem(type: .stat(
            textLabel: "Review Points",
            detailLabel: User.current.reviewPoints.formatted,
            accessibilityLabel: "\(User.current.reviewPoints) points from reviews"
        ))

        let practicePoints = HomeItem(type: .stat(
            textLabel: "Practice Points",
            detailLabel: User.current.practicePoints.formatted,
            accessibilityLabel: "\(User.current.practicePoints) points from practicing"
        ))

        let challengePoints = HomeItem(type: .stat(
            textLabel: "Challenge Points",
            detailLabel: User.current.challengePoints.formatted,
            accessibilityLabel: "\(User.current.challengePoints) points from challenges"
        ))

        return HomeSection(title: "POINTS", type: .score, items: [
            learningPoints,
            reviewPoints,
            practicePoints,
            challengePoints,
            HomeItem(type: .share)
        ])
    }

    private func makePointsItem() -> HomeItem {
        let textLabel = "Points Until Next Level"

        if let points = User.current.pointsUntilNextRank {
            return HomeItem(type: .stat(
                textLabel: textLabel,
                detailLabel: String(points),
                accessibilityLabel: "You need \(points) more points to reach the next level."
            ))
        } else {
            return HomeItem(type: .stat(
                textLabel: textLabel,
                detailLabel: "N/A",
                accessibilityLabel: "You are at the maximum level."
            ))
        }
    }

    private func makeStatsSection() -> HomeSection {
        let currentLevel = HomeItem(type: .stat(
            textLabel: "Current Level",
            detailLabel: "\(User.current.rankNumber)/21",
            accessibilityLabel: "You are level \(User.current.rankNumber) of 21."
        ))

        let dailyChallenges = HomeItem(type: .stat(
            textLabel: "Daily Challenges",
            detailLabel: String(User.current.dailyChallenges.count),
            accessibilityLabel: "\(User.current.dailyChallenges) daily challenges completed."
        ))

        return HomeSection(title: "STATS", type: .stats, items: [
            currentLevel,
            makePointsItem(),
            dailyChallenges
        ])
    }

    private func makeStreakSection() -> HomeSection {
        let streakDays = HomeItem(name: "Streak Reminder", type: .stat(
            textLabel: "Current Streak",
            detailLabel: "\(User.current.streakDays)",
            accessibilityLabel: "Your streak count is \(User.current.streakDays)"
        ))

        let bestStreak = HomeItem(name: "Streak Reminder", type: .stat(
            textLabel: "Best Streak",
            detailLabel: "\(User.current.bestStreak)",
            accessibilityLabel: "Your best streak count is \(User.current.bestStreak)"
        ))

        return HomeSection(title: "STREAK", type: .streak, items: [
            streakDays,
            bestStreak
        ])
    }

    private func makeHeader(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header",
            for: indexPath) as? HeaderSupplementaryView
        else {
            fatalError("Failed to dequeue a HeaderSupplementaryView.")
        }

        let section = sections[indexPath.section]
        view.textLabel.text = section.title

        if section.type == .badges {
            view.backgroundColor = .systemGroupedBackground
        }

        return view
    }

    /// Shows the activity ring and current rank.
    private func makeStatus(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Rank", for: indexPath) as? StatusCollectionViewCell else {
            fatalError("Failed to dequeue a StatusCollectionViewCell.")
        }

        return cell
    }

    /// Shows the user's total points in large text.
    private func makePointsSummary(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Points", for: indexPath) as? PointsCollectionViewCell else {
            fatalError("Failed to dequeue a PointsCollectionViewCell.")
        }

        cell.points = User.current.totalPoints
        return cell
    }

    /// Dequeue a reusable and clean collection view cell to show a stat.
    private func makeStat(in collectionView: UICollectionView, indexPath: IndexPath) -> StatCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Stat", for: indexPath) as? StatCollectionViewCell else {
            fatalError("Failed to dequeue a StatCollectionViewCell.")
        }

        let item = sections[indexPath.section].items[indexPath.item]

        switch item.type {
        case .stat(let textLabel, let detailLabel, let accessibilityLabel):
            cell.textLabel?.text = textLabel
            cell.detailLabel?.text = detailLabel
            cell.accessibilityLabel = accessibilityLabel
            cell.accessibilityIdentifier = item.name
        case .share:
            cell.textLabel?.text = "Share Score"
            cell.accessibilityTraits = .button
            cell.textLabel?.textColor = UIColor(bundleName: "Primary")

        default:
            fatalError("Invalid item type: \(item.type).")
        }

        return cell
    }

    /// Shows all the badges the user has earned.
    private func makeBadge(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Badge", for: indexPath) as? BadgeCollectionViewCell else {
            fatalError("Failed to dequeue a BadgeCollectionViewCell.")
        }

        cell.badge = badges[indexPath.item]
        return cell
    }
}
