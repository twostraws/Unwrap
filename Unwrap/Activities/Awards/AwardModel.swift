//
//  AwardModel.swift
//  Unwrap
//

import Foundation

struct AwardModel: Equatable {
    let startingTotal: Int
    let endingTotal: Int
    let earnedPoints: Int

    var crossesLevelBoundary: Bool {
        RankProgressSnapshot(totalPoints: startingTotal).level
            != RankProgressSnapshot(totalPoints: endingTotal).level
    }

    /// Presents an award without recording activity or changing saved progress.
    static func unchanged(for user: User) -> AwardModel {
        AwardModel(startingTotal: user.totalPoints, endingTotal: user.totalPoints)
    }

    #if DEBUG
    /// Exercises the award presentation without writing debug activity to local or cloud progress.
    static func previewingForDebug(points: Int, user: User) -> AwardModel {
        AwardModel(
            startingTotal: user.totalPoints,
            endingTotal: User.saturatingPointTotal([user.totalPoints, points])
        )
    }
    #endif

    /// Applies one completed activity, then captures the point totals either side of the change.
    static func applying(
        points: Int,
        reason: AwardReason,
        date: Date = .now,
        to user: User
    ) -> AwardModel {
        let startingTotal = user.totalPoints

        switch reason {
        case .challenge:
            user.completedChallenge(score: points, at: date)
        case .learning(let section):
            user.learnedSection(section)
        case .practice(let kind):
            user.completedPractice(kind, score: points)
        case .review(let section):
            user.reviewedSection(section)
        }

        return AwardModel(
            startingTotal: startingTotal,
            endingTotal: user.totalPoints
        )
    }

    private init(startingTotal: Int, endingTotal: Int) {
        self.startingTotal = startingTotal
        self.endingTotal = endingTotal
        earnedPoints = endingTotal - startingTotal
    }
}
