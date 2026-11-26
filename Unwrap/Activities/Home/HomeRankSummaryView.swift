//
//  HomeRankSummaryView.swift
//  Unwrap
//

import SwiftUI

struct HomeRankSummaryView: View {
    let user: User

    var body: some View {
        VStack(spacing: 0) {
            RankProgressView(totalPoints: user.totalPoints)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)

            VStack(spacing: 0) {
                Text("POINTS")
                    .font(.body)

                Text(user.totalPoints, format: .number)
                    .font(.largeTitle)
                    .contentTransition(.numericText(value: Double(user.totalPoints)))
            }
            .frame(maxWidth: .infinity, minHeight: 90)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(user.rankNumber), \(user.totalPoints) points")
        .accessibilityValue(nextLevelAccessibilityValue)
    }

    private var nextLevelAccessibilityValue: String {
        if let points = user.pointsUntilNextRank {
            "\(points) points until the next level"
        } else {
            "Maximum level reached"
        }
    }
}
