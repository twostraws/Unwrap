//
//  UserStateTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test("The test host runs in test mode, so tests never write to the live user record or iCloud")
    func testModeIsActive() {
        #expect(User.isRunningTests)
    }

    @Test("Test mode is switched on only by IS_TESTING=1")
    func testModeDetection() {
        #expect(User.isRunningTests(in: ["IS_TESTING": "1"]))
        #expect(User.isRunningTests(in: [:]) == false)
        #expect(User.isRunningTests(in: ["IS_TESTING": "0"]) == false)
        #expect(User.isRunningTests(in: ["IS_TESTING": "true"]) == false)
        #expect(User.isRunningTests(in: ["OTHER": "1"]) == false)
    }

    @Test("Every persisted field survives encoding and decoding")
    func completeCodableRoundTrip() throws {
        let original = makePopulatedUser()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(User.self, from: encoder.encode(original))

        expectSameProgress(decoded, original)
    }

    @Test("Replacing progress copies every field onto the existing user")
    func replacingProgress() {
        let source = makePopulatedUser()
        let target = User()
        target.learnedSection("closures")
        target.completedPractice("type-practice", score: 500)

        target.replaceProgress(with: source)

        expectSameProgress(target, source)
        #expect(target.hasLearned("closures") == false)
        #expect(target.practiceSessions.count(for: "type-practice") == 0)
    }

    @Test("Seen articles only ever move forward")
    func seenArticlesNeverMoveBackwards() {
        let user = User()

        user.seenUpToArticle(40)
        user.seenUpToArticle(12)

        #expect(user.latestNewsArticle == 40)
    }

    @Test("Removing a challenge that isn't in the history changes nothing")
    func removingUnknownChallenge() {
        let user = User()
        let kept = Date(timeIntervalSince1970: 5_000)
        user.completedChallenge(score: 100, at: kept)

        user.removeChallenge(id: Date(timeIntervalSince1970: 9_000))

        #expect(user.dailyChallenges == [ChallengeResult(date: kept, score: 100)])
    }

    @Test("A challenge counts as done only on the day it was completed")
    func challengeCompletionIsPerDay() throws {
        let calendar = Calendar.current
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 14, hour: 9)))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))
        let tonight = try #require(calendar.date(bySettingHour: 23, minute: 30, second: 0, of: today))
        let user = User(now: today)

        user.completedChallenge(score: 50, at: yesterday)
        #expect(user.hasCompletedChallenge(on: yesterday))
        #expect(user.hasCompletedChallenge(on: today) == false)

        user.completedChallenge(score: 75, at: today)
        #expect(user.hasCompletedChallenge(on: tonight))
    }

    @Test("Negative scores never reduce a point total")
    func negativeScoresAreIgnored() {
        let user = User()
        user.completedPractice("free-coding", score: 60)
        user.completedPractice("free-coding", score: -500)
        user.completedChallenge(score: -100, at: Date(timeIntervalSince1970: 1_000))

        #expect(user.practicePoints == 60)
        #expect(user.challengePoints == 0)
        #expect(user.totalPoints == 60)
        #expect(User.saturatingPointTotal([10, -5, 20]) == 30)
    }

    @Test("The longest possible streak saturates instead of overflowing")
    func streakSaturation() throws {
        let today = try #require(
            Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 14, hour: 9))
        )
        let user = User(now: today)
        user.streakDays = .max
        user.bestStreak = .max
        user.lastStreakEntry = try #require(Calendar.current.date(byAdding: .day, value: -1, to: today))

        user.reconcileStreak(at: today)

        #expect(user.streakDays == .max)
        #expect(user.bestStreak == .max)
    }

    @Test("A broken streak restarts without losing the best streak, then builds again")
    func streakRecovery() throws {
        let calendar = Calendar.current
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 20)))
        let user = User(now: start)

        // Three consecutive days, a missed day, then two more consecutive days.
        for dayOffset in [1, 2, 4, 5] {
            user.reconcileStreak(at: try #require(calendar.date(byAdding: .day, value: dayOffset, to: start)))
        }

        #expect(user.streakDays == 2)
        #expect(user.bestStreak == 3)
    }

    @Test("Chapter badge progress counts only sections that have been reviewed")
    func chapterBadgeProgress() throws {
        let chapter = try #require(Unwrap.chapters.first { $0.sections.count >= 2 })
        let badge = Badge(
            name: "Read",
            description: "",
            color: "",
            symbolName: "star.fill",
            criterion: "read",
            value: chapter.name.bundleName
        )
        let user = User()

        #expect(user.badgeProgress(badge) == "\n\nYou have not completed anything in this section yet.")

        // Reading a section without passing its review doesn't complete it.
        user.learnedSection(chapter.sections[0].bundleName)
        #expect(user.badgeProgress(badge) == "\n\nYou have not completed anything in this section yet.")

        user.reviewedSection(chapter.sections[0].bundleName)
        user.reviewedSection(chapter.sections[1].bundleName)
        #expect(
            user.badgeProgress(badge)
                == "\n\nYou have completed 2 out of \(chapter.sections.count) chapters!"
        )
        #expect(user.isBadgeEarned(badge) == (chapter.sections.count == 2))
    }

    private func makePopulatedUser() -> User {
        // ISO 8601 storage keeps whole seconds, so the fixture dates do too.
        let user = User(now: Date(timeIntervalSince1970: 1_600_000_000))
        user.streakDays = 3
        user.bestStreak = 9
        user.learnedSection("variables")
        user.reviewedSection("arrays")
        user.completedPractice("tap-to-code", score: 40)
        user.completedPractice("tap-to-code", score: 60)
        user.completedPractice("free-coding", score: 20)
        user.completedChallenge(score: 150, at: Date(timeIntervalSince1970: 1_600_000_100))
        user.completedChallenge(score: 250, at: Date(timeIntervalSince1970: 1_600_090_000))
        user.seenUpToArticle(77)
        user.readNewsStory(forURL: URL(staticString: "https://www.hackingwithswift.com/articles/77"))
        user.theme = "Dark"
        return user
    }

    private func expectSameProgress(
        _ user: User,
        _ expected: User,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(user.streakDays == expected.streakDays, sourceLocation: sourceLocation)
        #expect(user.bestStreak == expected.bestStreak, sourceLocation: sourceLocation)
        #expect(user.lastStreakEntry == expected.lastStreakEntry, sourceLocation: sourceLocation)
        #expect(user.practiceSessions == expected.practiceSessions, sourceLocation: sourceLocation)
        #expect(user.practicePoints == expected.practicePoints, sourceLocation: sourceLocation)
        #expect(user.dailyChallenges == expected.dailyChallenges, sourceLocation: sourceLocation)
        #expect(user.latestNewsArticle == expected.latestNewsArticle, sourceLocation: sourceLocation)
        #expect(user.articlesRead == expected.articlesRead, sourceLocation: sourceLocation)
        #expect(user.theme == expected.theme, sourceLocation: sourceLocation)
        #expect(user.learnPoints == expected.learnPoints, sourceLocation: sourceLocation)
        #expect(user.reviewPoints == expected.reviewPoints, sourceLocation: sourceLocation)
        #expect(user.totalPoints == expected.totalPoints, sourceLocation: sourceLocation)

        for section in ["variables", "arrays", "closures"] {
            #expect(user.hasLearned(section) == expected.hasLearned(section), sourceLocation: sourceLocation)
            #expect(user.hasReviewed(section) == expected.hasReviewed(section), sourceLocation: sourceLocation)
        }
    }
}
