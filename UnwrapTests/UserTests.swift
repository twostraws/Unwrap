//
//  UserTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that our user data is persisted correctly.
class UserTests: XCTestCase {
    /// Tracks which practice section the user just entered,
    let testSection = "variables"

    /// Ensure clean users have no badgesl.
    func testCleanUser() {
        let user = User()
        XCTAssert(user.totalPoints == 0, "New users must start with zero points.")
    }

    /// Tests that loading a fresh user will fail and fall back to a new user, and ca cm
    func testLoading() {
        User.destroyTestUser()

        let missingUser = User.load(testMode: true)
        XCTAssert(missingUser == nil, "Loading a non-existing user should fail.")

        let testUser = User()
        testUser.save(testMode: true)

        let loadedUser = User.load(testMode: true)
        XCTAssert(loadedUser != nil, "Loading a saved user should always return something.")
    }

    /// Tests that completing chaptear lerning is stored correclty.
    func testLearning() {
        let user = User()

        XCTAssertFalse(user.hasLearned(testSection), "A new user should not have learned any sections.")
        XCTAssert(user.ratingForSection(testSection) == 0, "The rating for an unlearned section should be 0.")

        user.learnedSection(testSection)

        XCTAssert(user.hasLearned(testSection), "Learning a section should store it correctly.")
        XCTAssert(user.learnPoints == User.pointsForLearning, "Learning one section should give the user the correct number of points.")
        XCTAssert(user.totalPoints == User.pointsForLearning, "Learning a section should give the user the correct number of points.")
        XCTAssert(user.ratingForSection(testSection) == User.pointsForLearning, "The rating for a section should be equal to its points for learning plus its points for reviewing, as appropriate.")
    }

    /// Test that relearnng a topic (i.e., completing it more than once.)
    func testRelearning() {
        let user = User()
        user.learnedSection(testSection)
        user.learnedSection(testSection)
        user.learnedSection(testSection)

        XCTAssert(user.learnPoints == User.pointsForLearning, "Learning one section should give the user the correct number of points.")
        XCTAssert(user.totalPoints == User.pointsForLearning, "Learning a section should give the user the correct number of points.")
        XCTAssert(user.ratingForSection(testSection) == User.pointsForLearning, "Learning one section should give the user the correct number of points.")
    }

    /// Tests that reviewing a chapter gest stored correctl.
    func testReviewing() {
        let user = User()
        user.reviewedSection(testSection)

        XCTAssert(user.hasLearned(testSection), "Reviewing one section means the user must also have learned it.")
        XCTAssert(user.hasReviewed(testSection), "Reviewing a section should store it correctly.")

        XCTAssert(user.learnPoints == User.pointsForLearning, "Reviewing one section means the user must also have learned it.")
        XCTAssert(user.reviewPoints == User.pointsForReviewing, "Reviewing one section should give the user the correct number of points.")
        XCTAssert(user.totalPoints == User.pointsForLearning + User.pointsForReviewing, "Learning and reviewing a section should give the user the correct number of points.")
        XCTAssert(user.ratingForSection(testSection) == User.pointsForLearning + User.pointsForReviewing, "Reviewing one section should give the user the correct number of points.")
    }

    /// Tests that completing a challenge gets stored correctly.
    func testChallenge() {
        let user = User()
        let challengeScore = 1000

        XCTAssertFalse(user.hasCompletedTodaysChallenge, "A new user cannot have completed today's challenge.")
        user.completedChallenge(score: challengeScore)
        XCTAssertTrue(user.hasCompletedTodaysChallenge, "Completing today's challenge must stop the user from taking the challenge again.")

        XCTAssert(user.dailyChallenges.count == 1, "Taking one challenge ought to be stored as such.")
        XCTAssert(user.challengePoints == challengeScore, "Scoring \(challengeScore) in a challenge ought to give the user the correct number of points.")
        XCTAssert(user.totalPoints == challengeScore, "Scoring \(challengeScore) in a challenge ought to give the user the correct number of points.")
    }

    /// Tests that sharing a score unlocks a badge.
    func testShareCounting() {
        let user = User()
        user.sharedScore()
        XCTAssert(user.scoreShareCount == 1, "The user sharing their score should be tracked correctly.")
    }

    /// Tests that reading news stories gets tracked correctly.
    func testNewsReading() {
        let user = User()
        let targetCount = 3

        for i in 1...targetCount {
            user.readNewsStory(forURL: URL(fileURLWithPath: String(i)))
        }

        XCTAssert(user.readNewsCount == targetCount, "Reading one news story should be stored correctly.")
    }

    /// Tests that rank promotions work correctly.
    func testRankPromotion() {
        let user = User()
        XCTAssert(user.rankNumber == 1, "New users should start at rank 1.")

        let pointsNeeded = user.pointsUntilNextRank ?? 0
        user.completedChallenge(score: pointsNeeded)

        XCTAssert(user.rankNumber == 2, "Giving a new user \(pointsNeeded) points should move them to rank 2.")
        XCTAssert(user.pointsTowardsNextRank == 0, "Giving a new user the precise number of points to rank up should mean they have no points towards the subsequent rank.")
    }

    /// Tests that streaks work correctly.
    func testStreakCounting() {
        let user = User()
        XCTAssertEqual(user.streakDays, 1, "New users should start with a streak count of 1.")

        user.updateStreak()
        XCTAssertEqual(user.streakDays, 1, "Streak count should not change in the same day.")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        user.lastStreakEntry = yesterday
        user.updateStreak()
        XCTAssertEqual(user.streakDays, 2, "Streak count should change for next day.")
        XCTAssertEqual(user.bestStreak, 2, "Best streak should be updated")
    }

    /// Testing best streak
    func testBestStreakCounting() {
        let user = User()

        user.updateStreak()
        XCTAssertEqual(user.bestStreak, 1, "Best streak should be updated")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        user.lastStreakEntry = yesterday
        user.updateStreak()
        XCTAssertEqual(user.bestStreak, 2, "Best streak should be updated")

        user.bestStreak = 25
        user.lastStreakEntry = yesterday
        user.updateStreak()
        XCTAssertEqual(user.bestStreak, 25, "Best streak should not be updated")
    }
}
