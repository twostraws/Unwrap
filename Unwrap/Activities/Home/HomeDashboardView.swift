//
//  HomeDashboardView.swift
//  Unwrap
//

import SwiftUI

struct HomeDashboardView: View {
    let user: User
    let badges: [Badge]
    let selectBadge: (Badge) -> Void

    var body: some View {
        List {
            Section {
                HomeRankSummaryView(user: user)
            }

            if user.hasLearned("nil-coalescing") {
                Section("Review an idea") {
                    OptionalReviewView(user: user)
                }
            }

            Section("Points") {
                HomeStatRow(
                    title: "Learning Points",
                    value: user.learnPoints.formatted(),
                    accessibilityLabel: "\(user.learnPoints) points from learning"
                )
                HomeStatRow(
                    title: "Review Points",
                    value: user.reviewPoints.formatted(),
                    accessibilityLabel: "\(user.reviewPoints) points from reviews"
                )
                HomeStatRow(
                    title: "Practice Points",
                    value: user.practicePoints.formatted(),
                    accessibilityLabel: "\(user.practicePoints) points from practicing"
                )
                HomeStatRow(
                    title: "Challenge Points",
                    value: user.challengePoints.formatted(),
                    accessibilityLabel: "\(user.challengePoints) points from challenges"
                )

                HomeShareLink(title: "Share Score", item: .score(for: user))
                    .tint(Color("BrandPrimary"))
            }

            Section("Stats") {
                HomeStatRow(
                    title: "Current Level",
                    value: "\(user.rankNumber)/21",
                    accessibilityLabel: "You are level \(user.rankNumber) of 21."
                )
                HomeStatRow(
                    title: "Points Until Next Level",
                    value: user.pointsUntilNextRank.map(String.init) ?? "N/A",
                    accessibilityLabel: pointsUntilNextLevelAccessibilityLabel
                )
                HomeStatRow(
                    title: "Daily Challenges",
                    value: String(user.dailyChallenges.count),
                    accessibilityLabel: dailyChallengesAccessibilityLabel
                )
            }

            Section("Streak") {
                HomeStatRow(
                    title: "Current Streak",
                    value: String(user.streakDays),
                    accessibilityLabel: "Your streak count is \(user.streakDays)"
                )
                HomeStatRow(
                    title: "Best Streak",
                    value: String(user.bestStreak),
                    accessibilityLabel: "Your best streak count is \(user.bestStreak)"
                )
            }

            Section("Badges") {
                BadgeGridView(badges: badges, user: user, select: selectBadge)
            }
        }
    }

    private var pointsUntilNextLevelAccessibilityLabel: String {
        if let points = user.pointsUntilNextRank {
            "You need \(points) more points to reach the next level."
        } else {
            "You are at the maximum level."
        }
    }

    private var dailyChallengesAccessibilityLabel: String {
        let count = user.dailyChallenges.count
        return count == 1
            ? "1 daily challenge completed."
            : "\(count) daily challenges completed."
    }
}
