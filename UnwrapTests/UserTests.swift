//
//  UserTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test("A clean user has no points")
    func cleanUser() {
        #expect(User().totalPoints == 0, "New users must start with zero points.")
    }

    @Test("A user can be loaded after being saved")
    func loading() {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: "TestUser")
        defer {
            if let previousTestData {
                defaults.set(previousTestData, forKey: "TestUser")
            } else {
                defaults.removeObject(forKey: "TestUser")
            }
        }

        User.destroyTestUser()
        #expect(User.load(testMode: true) == nil, "Loading a nonexistent user should fail.")

        User().save(testMode: true)

        #expect(User.load(testMode: true) != nil, "Loading a saved user should succeed.")
    }

    @Test("Learning a section records its points")
    func learning() {
        let user = User()

        #expect(!user.hasLearned(legacyTestSection), "A new user should not have learned any sections.")
        #expect(user.ratingForSection(legacyTestSection) == 0)

        user.learnedSection(legacyTestSection)

        #expect(user.hasLearned(legacyTestSection))
        #expect(user.learnPoints == User.pointsForLearning)
        #expect(user.totalPoints == User.pointsForLearning)
        #expect(user.ratingForSection(legacyTestSection) == User.pointsForLearning)
    }

    @Test("Repeated learning remains idempotent", arguments: [1, 2, 3, 10])
    func repeatedLearning(completionCount: Int) {
        let user = User()

        for _ in 0..<completionCount {
            user.learnedSection(legacyTestSection)
        }

        #expect(user.learnPoints == User.pointsForLearning)
        #expect(user.totalPoints == User.pointsForLearning)
        #expect(user.ratingForSection(legacyTestSection) == User.pointsForLearning)
    }

    @Test("Reviewing a section records learning and review points")
    func reviewing() {
        let user = User()

        user.reviewedSection(legacyTestSection)

        #expect(user.hasLearned(legacyTestSection))
        #expect(user.hasReviewed(legacyTestSection))
        #expect(user.learnPoints == User.pointsForLearning)
        #expect(user.reviewPoints == User.pointsForReviewing)
        #expect(user.totalPoints == User.pointsForLearning + User.pointsForReviewing)
        #expect(
            user.ratingForSection(legacyTestSection)
                == User.pointsForLearning + User.pointsForReviewing
        )
    }

    @Test("Completing a challenge records its score")
    func challenge() {
        let user = User()
        let challengeScore = 1_000

        #expect(!user.hasCompletedTodaysChallenge)

        user.completedChallenge(score: challengeScore)

        #expect(user.hasCompletedTodaysChallenge)
        #expect(user.dailyChallenges.count == 1)
        #expect(user.challengePoints == challengeScore)
        #expect(user.totalPoints == challengeScore)
    }

    @Test("Sharing a score is counted")
    func shareCounting() {
        let user = User()

        user.sharedScore()

        #expect(user.scoreShareCount == 1)
    }

    @Test("Reading distinct news stories is counted")
    func newsReading() {
        let user = User()
        let targetCount = 3

        for index in 0..<targetCount {
            user.readNewsStory(forURL: URL(fileURLWithPath: "/news/legacy-\(index)"))
        }

        #expect(user.readNewsCount == targetCount)
    }

    @Test("Reaching a rank boundary promotes the user")
    func rankPromotion() throws {
        let user = User()
        let pointsNeeded = try #require(user.pointsUntilNextRank)

        #expect(user.rankNumber == 1)

        user.completedChallenge(score: pointsNeeded)

        #expect(user.rankNumber == 2)
        #expect(user.pointsTowardsNextRank == 0)
    }

    @Test("A consecutive day increments the current and best streak")
    func streakCounting() throws {
        let user = User()
        let today = Date()

        user.lastStreakEntry = today
        user.reconcileStreak(at: today)
        #expect(user.streakDays == 1)

        user.lastStreakEntry = try #require(Calendar.current.date(byAdding: .day, value: -1, to: today))
        user.reconcileStreak(at: today)

        #expect(user.streakDays == 2)
        #expect(user.bestStreak == 2)
    }

    @Test("A current streak never reduces the best streak")
    func bestStreakCounting() throws {
        let user = User()
        let today = Date()
        let yesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: today))

        user.lastStreakEntry = yesterday
        user.reconcileStreak(at: today)
        #expect(user.bestStreak == 2)

        user.bestStreak = 25
        user.lastStreakEntry = yesterday
        user.reconcileStreak(at: today)

        #expect(user.bestStreak == 25)
    }

    @Test("Resetting progress clears challenge and practice data")
    func legacyResetProgress() {
        let user = User()
        user.dailyChallenges.append(ChallengeResult(date: Date(), score: 1_000))
        user.practiceSessions.insert("Test session")
        user.practicePoints = 100

        user.resetProgress()

        #expect(user.dailyChallenges.isEmpty)
        #expect(user.practiceSessions.isEmpty)
        #expect(user.practicePoints == 0)
    }

    private var legacyTestSection: String { "variables" }
}
