//
//  BadgeTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that badges unlock at the correct time.
class BadgeTests: XCTestCase {
    /// Stores all our badges so we can work with them.
    let badges = Bundle.main.decode([Badge].self, from: "Badges.json")

    /// Pulls out a badge with a specific name, or throws a test error if the badge is unknown.
    func badge(named: String) throws -> Badge {
        guard let badge = badges.first(where: { $0.name == named }) else {
            throw TestErrors.badBadge
        }

        return badge
    }

    /// Tests that new users have no badges unlocked.
    func testNoBadges() {
        let user = User()

        for badge in badges {
            XCTAssertFalse(user.isBadgeEarned(badge), "A new user should have no badges unlocked.")
        }
    }

    /// Tests that each of the read badges get unlocked when all the relevant chapters are read.
    func testReadBadges() throws {
        let user = User()
        let readBadges = badges.filter { $0.criterion == "read" }

        for badge in readBadges {
            guard let conditionChapter = Unwrap.chapters.first(where: {
                $0.name.bundleName == badge.value }) else {
                    throw TestErrors.badChapter
                }

            for section in conditionChapter.sections {
                user.reviewedSection(section.bundleName)
            }

            XCTAssert(user.isBadgeEarned(badge))
        }
    }

    /// Tests that practice badges get unlocked when an activity has been completed 10 times.
    func testPracticeCounting() throws {
        let user = User()
        let practiceBadges = badges.filter { $0.criterion == "practice" }

        for badge in practiceBadges {
            for i in 1...10 {
                XCTAssertFalse(user.isBadgeEarned(badge), "Completing \(badge.value) \(i) time(s) should not have unlocked the badge \(badge.name).")

                user.completedPractice(badge.value, score: User.pointsForPracticing)
            }

            XCTAssertTrue(user.isBadgeEarned(badge), "Completing \(badge.value) 10 times should unlock the badge \(badge.name).")
        }
    }

    /// Tests that the streak badges get unlocked when the user's streak is appropriately long.
    func testStreaks() throws {
        let user = User()
        let testBadges = badges.filter { $0.criterion == "streak" }

        // Sort the badges by their value, so that the shortest streaks are checked first.
        let sortedBadges = try testBadges.sorted {
            guard let firstInt = Int($0.value), let secondInt = Int($1.value) else {
                throw TestErrors.badBadge
            }

            return firstInt < secondInt
        }

        // Loop over all the badges, making sure that it gets unlocked now, but also loop again to make sure that later badges *aren't* unlocked.
        for (index, badge) in sortedBadges.enumerated() {
            user.bestStreak = Int(badge.value) ?? 0

            XCTAssertTrue(user.isBadgeEarned(badge), "Having a streak of \(badge.value) should unlock the badge \(badge.name).")

            let otherBadges = sortedBadges.suffix(from: index + 1)

            for badge in otherBadges {
                XCTAssertFalse(user.isBadgeEarned(badge), "Having a streak of \(badge.value) should not unlock the badge \(badge.name).")
            }
        }
    }

    /// Tests that the challenge badges are unlocked as the user completes daily challenges enough times.
    func testChallenges() throws {
        let user = User()
        let testBadges = badges.filter { $0.criterion == "challenge" }

        // Sort the badges by their value, so that the shortest challenge requirements are checked first.
        let sortedBadges = try testBadges.sorted {
            guard let firstInt = Int($0.value), let secondInt = Int($1.value) else {
                throw TestErrors.badBadge
            }

            return firstInt < secondInt
        }

        // Loop over all the badges, making sure that it gets unlocked now, but also loop again to make sure that later badges *aren't* unlocked.
        for (index, badge) in sortedBadges.enumerated() {
            let needed = (Int(badge.value) ?? 0) -   user.dailyChallenges.count

            for _ in 1...needed {
                let result = ChallengeResult(date: Date(), score: 1000)
                user.dailyChallenges.append(result)
            }

            XCTAssertTrue(user.isBadgeEarned(badge), "Completing \(badge.value) challenges should unlock the badge \(badge.name).")

            let otherBadges = sortedBadges.suffix(from: index + 1)

            for badge in otherBadges {
                XCTAssertFalse(user.isBadgeEarned(badge), "Completing \(badge.value) challenges should not unlock the badge \(badge.name).")
            }
        }
    }

    /// Test that the reading badge gets unlocked only when enough news stories have been read.
    func testReadingBadge() throws {
        let user = User()
        let readerBadge = try badge(named: "Keen Reader")

        guard let targetCount = Int(readerBadge.value) else {
            throw TestErrors.badBadge
        }

        for _ in 1...targetCount {
            user.readNewsStory()
        }

        XCTAssertTrue(user.isBadgeEarned(readerBadge), "Reading \(targetCount) news stories should unlock the badge \(readerBadge.name).")
    }

    /// Tests that the social sharing badge gets unlocked when the user has shared their score.
    func testScoreSharingBadge() throws {
        let user = User()
        let scoreShareBadge = try badge(named: "Social Sharer")

        user.sharedScore()
        XCTAssertTrue(user.isBadgeEarned(scoreShareBadge), "Sharing their score at least once shhould unlock the badge \(scoreShareBadge.name).")
    }
}
