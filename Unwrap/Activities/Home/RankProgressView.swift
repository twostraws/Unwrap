//
//  RankProgressView.swift
//  Unwrap
//

import SwiftUI

/// Displays the user's current rank and its progress ring.
struct RankProgressView: View {
    enum Style {
        case home
        case award
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let totalPoints: Int
    let style: Style

    @State private var displayedLevel: Int
    @State private var displayedFraction: Double
    @State private var renderedTotalPoints: Int

    init(totalPoints: Int, style: Style = .home) {
        self.totalPoints = totalPoints
        self.style = style

        let snapshot = RankProgressSnapshot(totalPoints: totalPoints)
        _displayedLevel = State(initialValue: snapshot.level)
        _displayedFraction = State(initialValue: snapshot.fraction)
        _renderedTotalPoints = State(initialValue: totalPoints)
    }

    var body: some View {
        ZStack {
            ProgressRing(
                progress: displayedFraction,
                startColor: Color("Rank-Start"),
                endColor: Color("Rank-End"),
                trackColor: Color("StatusViewRingBackground"),
                lineWidth: 10,
                showsEndShadow: style == .award
            )
            .padding(15)

            Image("Rank Level \(displayedLevel)")
                .resizable()
                .renderingMode(style == .award ? .template : .original)
                .scaledToFit()
                .foregroundStyle(.white)
                .padding(40)
        }
        .aspectRatio(1.25, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(targetSnapshot.level)")
        .accessibilityValue(accessibilityProgress)
        .task(id: totalPoints) {
            await updateProgress()
        }
    }

    private var targetSnapshot: RankProgressSnapshot {
        RankProgressSnapshot(totalPoints: totalPoints)
    }

    private var accessibilityProgress: String {
        if targetSnapshot.level == User.rankLevels.count - 1 {
            return "Maximum level"
        } else {
            let percentage = Int((targetSnapshot.fraction * 100).rounded())
            return "\(percentage) percent progress toward level \(targetSnapshot.level + 1)"
        }
    }

    private func updateProgress() async {
        let previousTotalPoints = renderedTotalPoints
        renderedTotalPoints = totalPoints

        guard previousTotalPoints != totalPoints else {
            snap(to: targetSnapshot)
            return
        }

        guard reduceMotion == false else {
            snap(to: targetSnapshot)
            return
        }

        let previousSnapshot = RankProgressSnapshot(totalPoints: previousTotalPoints)
        let target = targetSnapshot
        var targetFraction = target.fraction

        if style == .award, totalPoints > previousTotalPoints {
            if target.fraction < previousSnapshot.fraction {
                targetFraction += 1
            } else if target.fraction == previousSnapshot.fraction {
                targetFraction = 1
            }
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            displayedLevel = target.level
            displayedFraction = previousSnapshot.fraction
        }

        await Task.yield()

        withAnimation(.easeInOut(duration: 2)) {
            displayedFraction = targetFraction
        }
    }

    private func snap(to snapshot: RankProgressSnapshot) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            displayedLevel = snapshot.level
            displayedFraction = snapshot.fraction
        }
    }
}
