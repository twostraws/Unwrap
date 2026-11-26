//
//  UserPersistenceTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test("Persistence retains the shipping keys")
    func persistenceKeys() {
        #expect(User.liveUserKey == "User")
        #expect(User.testUserKey == "TestUser")
        #expect(User.syncTimestampKey == "ZephyrSyncKey")
    }

    @Test("User dates are stored as ISO 8601 and round-trip")
    func iso8601RoundTrip() throws {
        let defaults = UserDefaults.standard
        let previousData = defaults.data(forKey: User.testUserKey)
        defer { restore(previousData, forKey: User.testUserKey, in: defaults) }

        let date = Date(timeIntervalSince1970: 1_581_318_000)
        let user = User(now: date)
        user.streakDays = 6
        user.practicePoints = 125
        user.save(testMode: true)

        let data = try #require(defaults.data(forKey: User.testUserKey))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let encodedDate = try #require(object["lastStreakEntry"] as? String)
        #expect(ISO8601DateFormatter().date(from: encodedDate) == date)

        let loaded = try #require(User.load(testMode: true))
        #expect(loaded.lastStreakEntry == date)
        #expect(loaded.streakDays == 6)
        #expect(loaded.practicePoints == 125)
    }

    @Test("Missing historical fields receive their defaults")
    func missingFieldsUseDefaults() throws {
        let user = try decoder().decode(User.self, from: Data("{}".utf8))

        #expect(user.streakDays == 1)
        #expect(user.bestStreak == 1)
        #expect(user.lastStreakEntry.isSameDay(as: .now))
        #expect(user.learnPoints == 0)
        #expect(user.reviewPoints == 0)
        #expect(user.practiceSessions.isEmpty)
        #expect(user.practicePoints == 0)
        #expect(user.dailyChallenges.isEmpty)
        #expect(user.latestNewsArticle == 0)
        #expect(user.articlesRead.isEmpty)
        #expect(user.theme == "Light")
    }

    @Test("Test users remain isolated from the live local record")
    func testStorageIsLocal() throws {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: User.testUserKey)
        let previousLiveData = defaults.data(forKey: User.liveUserKey)
        defer {
            restore(previousTestData, forKey: User.testUserKey, in: defaults)
            restore(previousLiveData, forKey: User.liveUserKey, in: defaults)
        }

        let liveMarker = Data("live".utf8)
        defaults.set(liveMarker, forKey: User.liveUserKey)

        let user = User()
        user.practicePoints = 222
        user.save(testMode: true)

        #expect(User.load(testMode: true)?.practicePoints == 222)
        #expect(defaults.data(forKey: User.liveUserKey) == liveMarker)
    }

    @Test("Timestamp selection prefers cloud unless local is strictly newer, including equal timestamps")
    func timestampWinnerRules() {
        let early = Date(timeIntervalSince1970: 100)
        let late = Date(timeIntervalSince1970: 300)

        #expect(User.localRecordWins(localDate: late, cloudDate: early))
        #expect(User.localRecordWins(localDate: early, cloudDate: nil))
        #expect(User.localRecordWins(localDate: nil, cloudDate: nil))
        #expect(User.localRecordWins(localDate: early, cloudDate: late) == false)
        #expect(User.localRecordWins(localDate: late, cloudDate: late) == false)
        #expect(User.localRecordWins(localDate: nil, cloudDate: late) == false)
    }

    @Test("The frozen shipping 1.5 payload decodes without losing progress")
    func shippingV15FixtureDecodes() throws {
        let user = try decoder().decode(User.self, from: shippingV15FixtureData())

        #expect(user.streakDays == 42)
        #expect(user.bestStreak == 120)
        #expect(user.hasLearned("closures"))
        #expect(user.hasReviewed("variables"))
        #expect(user.practiceSessions.count(for: "type-practice") == 7)
        #expect(user.practiceSessions.count(for: "free-coding") == 3)
        #expect(user.practicePoints == 9_876)
        #expect(user.dailyChallenges.count == 3)
        #expect(user.challengePoints == 600)
        #expect(user.latestNewsArticle == 456)
        #expect(user.articlesRead.count == 2)
        #expect(user.theme == "Dark")
    }

    private func restore(_ data: Data?, forKey key: String, in defaults: UserDefaults) {
        if let data {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func shippingV15FixtureData() throws -> Data {
        let bundle = Bundle(for: UserPersistenceFixtureBundleToken.self)
        let fixtureURL = bundle.url(
            forResource: "User-v1.5",
            withExtension: "json",
            subdirectory: "Fixtures"
        ) ?? bundle.url(forResource: "User-v1.5", withExtension: "json")

        return try Data(contentsOf: #require(fixtureURL))
    }
}

private final class UserPersistenceFixtureBundleToken {
}
