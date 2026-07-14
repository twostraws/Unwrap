//
//  BadgeTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    private nonisolated struct BadgeTestMetadata: Decodable {
        let name: String
        let criterion: String
    }

    private nonisolated enum BadgeFixtures {
        static let allNames = metadata.map(\.name)

        static let readNames = metadata
            .filter { $0.criterion == "read" }
            .map(\.name)

        static let practiceNames = metadata
            .filter { $0.criterion == "practice" }
            .map(\.name)

        static let streakNames = metadata
            .filter { $0.criterion == "streak" }
            .map(\.name)

        static let challengeNames = metadata
            .filter { $0.criterion == "challenge" }
            .map(\.name)

        private static let metadata = loadMetadata()

        private static func loadMetadata() -> [BadgeTestMetadata] {
            guard let jsonURL = Bundle.main.url(forResource: "Badges.json", withExtension: nil) else {
                preconditionFailure("Unable to locate Badges.json.")
            }

            do {
                let jsonData = try Data(contentsOf: jsonURL)
                return try JSONDecoder().decode([BadgeTestMetadata].self, from: jsonData)
            } catch {
                preconditionFailure("Unable to decode Badges.json: \(error)")
            }
        }
    }

    @Test("A new user has not earned a badge", arguments: BadgeFixtures.allNames)
    func newUserHasNoBadges(badgeName: String) throws {
        let badge = try badge(named: badgeName)

        #expect(!User().isBadgeEarned(badge), "A new user should not have earned \(badge.name).")
    }

    @Test("Reading a whole chapter earns its badge", arguments: BadgeFixtures.readNames)
    func readBadges(badgeName: String) throws {
        let badge = try badge(named: badgeName)
        let chapter = try #require(
            Unwrap.chapters.first { $0.name.bundleName == badge.value },
            "No chapter matches the badge value \(badge.value)."
        )
        let user = User()

        for section in chapter.sections {
            user.reviewedSection(section.bundleName)
        }

        #expect(user.isBadgeEarned(badge))
    }

    @Test("Ten practice sessions earn a practice badge", arguments: BadgeFixtures.practiceNames)
    func practiceCounting(badgeName: String) throws {
        let badge = try badge(named: badgeName)
        let user = User()

        for completedCount in 0..<10 {
            #expect(
                !user.isBadgeEarned(badge),
                "Completing \(badge.value) \(completedCount) times should not earn \(badge.name)."
            )
            user.completedPractice(badge.value, score: User.pointsForPracticing)
        }

        #expect(user.isBadgeEarned(badge), "Completing \(badge.value) 10 times should earn \(badge.name).")
    }

    @Test("A streak badge unlocks at its threshold", arguments: BadgeFixtures.streakNames)
    func streakBadges(badgeName: String) throws {
        let badge = try badge(named: badgeName)
        let threshold = try #require(Int(badge.value), "Badge \(badge.name) has a non-numeric value.")
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")
        let laterBadges = badges.filter {
            $0.criterion == "streak" && (Int($0.value) ?? 0) > threshold
        }
        let user = User()
        user.bestStreak = threshold

        #expect(user.isBadgeEarned(badge), "A streak of \(threshold) should earn \(badge.name).")

        for laterBadge in laterBadges {
            #expect(
                !user.isBadgeEarned(laterBadge),
                "A streak of \(threshold) should not earn \(laterBadge.name)."
            )
        }
    }

    @Test("A challenge badge unlocks at its threshold", arguments: BadgeFixtures.challengeNames)
    func challengeBadges(badgeName: String) throws {
        let badge = try badge(named: badgeName)
        let threshold = try #require(Int(badge.value), "Badge \(badge.name) has a non-numeric value.")
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")
        let laterBadges = badges.filter {
            $0.criterion == "challenge" && (Int($0.value) ?? 0) > threshold
        }
        let user = User()
        user.dailyChallenges = (0..<threshold).map {
            ChallengeResult(date: Date(timeIntervalSince1970: Double($0)), score: 1_000)
        }

        #expect(user.isBadgeEarned(badge), "Completing \(threshold) challenges should earn \(badge.name).")

        for laterBadge in laterBadges {
            #expect(
                !user.isBadgeEarned(laterBadge),
                "Completing \(threshold) challenges should not earn \(laterBadge.name)."
            )
        }
    }

    @Test("Reading enough news stories earns the reader badge")
    func readingBadge() throws {
        let badge = try badge(named: "Keen Reader")
        let targetCount = try #require(Int(badge.value), "Keen Reader has a non-numeric value.")
        let user = User()

        for index in 0..<targetCount {
            user.readNewsStory(forURL: URL(fileURLWithPath: "/news/\(index)"))
        }

        #expect(user.isBadgeEarned(badge), "Reading \(targetCount) stories should earn \(badge.name).")
    }

    @Test("Sharing a score earns the social badge")
    func scoreSharingBadge() throws {
        let badge = try badge(named: "Social Sharer")
        let user = User()

        user.sharedScore()

        #expect(user.isBadgeEarned(badge), "Sharing a score should earn \(badge.name).")
    }

    private func badge(named name: String) throws -> Badge {
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")
        return try #require(badges.first { $0.name == name }, "Unknown badge \(name).")
    }
}
