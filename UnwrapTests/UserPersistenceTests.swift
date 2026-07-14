//
//  UserPersistenceTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    private var liveKey: String { "User" }
    private var testKey: String { "TestUser" }

    @Test("A complete user round-trips through test storage")
    func fullRoundTrip() {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: testKey)
        defer { restore(previousTestData, forKey: testKey) }

        defaults.removeObject(forKey: testKey)
        let user = User()
        let stableNow = Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded(.down))
        let firstArticle = URL(fileURLWithPath: "/news/round-trip-1")
        let secondArticle = URL(fileURLWithPath: "/news/round-trip-2")

        user.streakDays = 6
        user.bestStreak = 9
        user.lastStreakEntry = stableNow
        user.learnedSection("variables")
        user.reviewedSection("functions")
        user.completedPractice("type-practice", score: 20)
        user.completedPractice("type-practice", score: 30)
        user.completedPractice("free-coding", score: 10)
        user.dailyChallenges = [
            ChallengeResult(date: stableNow, score: 150),
            ChallengeResult(date: stableNow.addingTimeInterval(-3_600), score: 100)
        ]
        user.sharedScore()
        user.sharedScore()
        user.seenUpToArticle(123)
        user.readNewsStory(forURL: firstArticle)
        user.readNewsStory(forURL: secondArticle)
        user.theme = "Dark"

        user.save(testMode: true)

        guard let loaded = User.load(testMode: true) else {
            Issue.record("A fully encoded user could not be loaded")
            return
        }

        #expect(loaded.streakDays == 6)
        #expect(loaded.bestStreak == 9)
        #expect(loaded.lastStreakEntry == stableNow)
        #expect(loaded.hasLearned("variables"))
        #expect(loaded.hasLearned("functions"))
        #expect(loaded.hasReviewed("variables") == false)
        #expect(loaded.hasReviewed("functions"))
        #expect(loaded.learnPoints == 200)
        #expect(loaded.reviewPoints == 100)
        #expect(loaded.practiceSessions.count == 2)
        #expect(loaded.practiceSessions.count(for: "type-practice") == 2)
        #expect(loaded.practiceSessions.count(for: "free-coding") == 1)
        #expect(loaded.practicePoints == 60)
        #expect(loaded.dailyChallenges.map(\.score) == [150, 100])
        #expect(loaded.dailyChallenges.map(\.date) == [stableNow, stableNow.addingTimeInterval(-3_600)])
        #expect(loaded.challengePoints == 250)
        #expect(loaded.scoreShareCount == 2)
        #expect(loaded.latestNewsArticle == 123)
        #expect(loaded.articlesRead == [firstArticle, secondArticle])
        #expect(loaded.readNewsCount == 2)
        #expect(loaded.theme == "Dark")
        #expect(loaded.totalPoints == 610)
    }

    @Test("Missing and corrupt test storage return nil")
    func missingAndCorruptStorage() {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: testKey)
        defer { restore(previousTestData, forKey: testKey) }

        defaults.removeObject(forKey: testKey)
        #expect(User.load(testMode: true) == nil)

        defaults.set(Data("not valid user JSON".utf8), forKey: testKey)
        #expect(User.load(testMode: true) == nil)
    }

    @Test("Live and test storage are isolated and explicit modes override the environment")
    func liveAndTestIsolation() {
        let defaults = UserDefaults.standard
        let previousLiveData = defaults.data(forKey: liveKey)
        let previousTestData = defaults.data(forKey: testKey)
        defer {
            restore(previousLiveData, forKey: liveKey)
            restore(previousTestData, forKey: testKey)
        }

        defaults.removeObject(forKey: liveKey)
        defaults.removeObject(forKey: testKey)

        let liveUser = User()
        liveUser.practicePoints = 111
        liveUser.save(testMode: false)

        let testUser = User()
        testUser.practicePoints = 222
        testUser.save(testMode: true)

        #expect(User.load(testMode: false)?.practicePoints == 111)
        #expect(User.load(testMode: true)?.practicePoints == 222)
    }

    @Test("Default persistence uses test storage when IS_TESTING is enabled")
    func defaultsToTestStorage() {
        let defaults = UserDefaults.standard
        let previousLiveData = defaults.data(forKey: liveKey)
        let previousTestData = defaults.data(forKey: testKey)
        defer {
            restore(previousLiveData, forKey: liveKey)
            restore(previousTestData, forKey: testKey)
        }

        defaults.removeObject(forKey: liveKey)
        defaults.removeObject(forKey: testKey)

        let liveUser = User()
        liveUser.practicePoints = 10
        liveUser.save(testMode: false)

        let defaultUser = User()
        defaultUser.practicePoints = 20
        defaultUser.save()

        #expect(User.isRunningTests)
        #expect(User.load()?.practicePoints == 20)
        #expect(User.load(testMode: true)?.practicePoints == 20)
        #expect(User.load(testMode: false)?.practicePoints == 10)
    }

    @Test("A mutation persists its receiver rather than User.current")
    func mutationSavesReceiver() {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: testKey)
        let previousCurrentUser: User? = User.current
        defer {
            restore(previousTestData, forKey: testKey)
            User.current = previousCurrentUser
        }

        defaults.removeObject(forKey: testKey)
        let currentUser = User()
        currentUser.practicePoints = 999
        User.current = currentUser

        let receiver = User()
        receiver.completedPractice("type-practice", score: 25)

        guard let loaded = User.load(testMode: true) else {
            Issue.record("The mutated receiver was not saved")
            return
        }

        #expect(loaded.practicePoints == 25)
        #expect(loaded.practiceSessions.count(for: "type-practice") == 1)
    }

    @Test("Unknown future keys do not prevent decoding")
    func unknownKeys() throws {
        let user = User()
        user.practicePoints = 321
        user.theme = "Dark"

        let encoded = try makeEncoder().encode(user)
        var object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["futureProperty"] = ["enabled": true, "name": "Future"]
        let data = try JSONSerialization.data(withJSONObject: object)
        let decoded = try makeDecoder().decode(User.self, from: data)

        #expect(decoded.practicePoints == 321)
        #expect(decoded.theme == "Dark")
    }

    @Test("A legacy snapshot with missing keys receives defaults")
    func legacyMissingKeys() throws {
        let emptyLegacyData = Data("{}".utf8)
        let emptyLegacyUser = try makeDecoder().decode(User.self, from: emptyLegacyData)

        #expect(emptyLegacyUser.streakDays == 1)
        #expect(emptyLegacyUser.bestStreak == 1)
        #expect(emptyLegacyUser.lastStreakEntry.isSameDay(as: Date()))
        #expect(emptyLegacyUser.learnPoints == 0)
        #expect(emptyLegacyUser.reviewPoints == 0)
        #expect(emptyLegacyUser.practiceSessions.isEmpty)
        #expect(emptyLegacyUser.practicePoints == 0)
        #expect(emptyLegacyUser.dailyChallenges.isEmpty)
        #expect(emptyLegacyUser.scoreShareCount == 0)
        #expect(emptyLegacyUser.latestNewsArticle == 0)
        #expect(emptyLegacyUser.articlesRead.isEmpty)
        #expect(emptyLegacyUser.theme == "Light")

        let partialUser = User()
        partialUser.practicePoints = 73
        partialUser.theme = "Dark"
        partialUser.scoreShareCount = 4
        partialUser.latestNewsArticle = 88
        partialUser.articlesRead = [URL(fileURLWithPath: "/legacy/article")]

        let encoded = try makeEncoder().encode(partialUser)
        var object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "theme")
        object.removeValue(forKey: "scoreShareCount")
        object.removeValue(forKey: "latestNewsArticle")
        object.removeValue(forKey: "articlesRead")
        let partialData = try JSONSerialization.data(withJSONObject: object)
        let decodedPartialUser = try makeDecoder().decode(User.self, from: partialData)

        #expect(decodedPartialUser.practicePoints == 73)
        #expect(decodedPartialUser.theme == "Light")
        #expect(decodedPartialUser.scoreShareCount == 0)
        #expect(decodedPartialUser.latestNewsArticle == 0)
        #expect(decodedPartialUser.articlesRead.isEmpty)
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func restore(_ data: Data?, forKey key: String) {
        if let data {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
