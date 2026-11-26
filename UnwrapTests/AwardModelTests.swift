//
//  AwardModelTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Shared award model")
struct AwardModelTests {
    @Test("An award mutates its user exactly once")
    func appliesExactlyOnce() {
        let user = User()
        let model = AwardModel.applying(
            points: 40,
            reason: .practice(kind: "type-practice"),
            to: user
        )

        #expect(user.practicePoints == 40)
        #expect(user.practiceSessions.count(for: "type-practice") == 1)
        #expect(model.startingTotal == 0)
        #expect(model.endingTotal == 40)
        #expect(model.earnedPoints == 40)
    }

    @Test("Zero-point review grants preserve the legacy reviewed mutation")
    func zeroPointReview() {
        let user = User()
        user.learnedSection("variables")
        let model = AwardModel.applying(
            points: 0,
            reason: .review(section: "variables"),
            to: user
        )

        #expect(user.hasReviewed("variables"))
        #expect(user.reviewPoints == User.pointsForReviewing)
        #expect(model.earnedPoints == User.pointsForReviewing)
    }

    @Test("Challenge grants use their injected date")
    func challengeDate() throws {
        let user = User()
        let date = Date(timeIntervalSince1970: 1_234)
        _ = AwardModel.applying(
            points: 150,
            reason: .challenge,
            date: date,
            to: user
        )

        let result = try #require(user.dailyChallenges.first)
        #expect(result.date == date)
        #expect(result.score == 150)
    }

    @Test("Level-boundary calculation covers ordinary and rollover awards")
    func levelBoundaries() {
        let user = User()
        user.practicePoints = 100
        let ordinary = AwardModel.applying(
            points: 20,
            reason: .practice(kind: "type-practice"),
            to: user
        )
        let rollover = AwardModel.applying(
            points: 100,
            reason: .practice(kind: "type-practice"),
            to: user
        )

        #expect(ordinary.crossesLevelBoundary == false)
        #expect(rollover.crossesLevelBoundary)
    }
}
