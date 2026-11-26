//
//  User.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftUI

@Observable
final class User: Codable {
    enum CodingKeys: String, CodingKey {
        case streakDays
        case bestStreak
        case lastStreakEntry

        case learnedSections
        case reviewedSections
        case practiceSessions
        case practicePoints
        case dailyChallenges

        case latestNewsArticle
        case articlesRead

        case theme
    }

    // MARK: - Stored properties

    /// Tracks app launches over days.
    var streakDays = 1
    var bestStreak = 1
    var lastStreakEntry = Date()

    /// Stores the list of sections the user has learned.
    private var learnedSections = Set<String>()

    /// Stores the list of sections the user has reviewed themselves on.
    private var reviewedSections = Set<String>()

    /// How many times this user has completed each type of practice.
    internal var practiceSessions = CountedSet<String>()

    /// The number of points this user earned through practicing.
    var practicePoints = 0

    /// An array of all the days the user has completed a challenge.
    var dailyChallenges = [ChallengeResult]()

    /// Stores the highest article ID the user has read.
    var latestNewsArticle = 0

    /// The number of times the user has read a news article.
    var readNewsCount: Int {
        return articlesRead.count
    }

    /// Tracks the currently enabled theme.
    var theme = "Light"

    /// Tracks which articles the user has read.
    var articlesRead = Set<URL>()

    // MARK: - Computed properties

    /// The number of points this user earned through learning.
    var learnPoints: Int {
        return learnedSections.count * User.pointsForLearning
    }

    /// The number of points this user earned through learning.
    var reviewPoints: Int {
        return reviewedSections.count * User.pointsForReviewing
    }

    /// The total number of points for this user.
    var totalPoints: Int {
        Self.saturatingPointTotal([
            learnPoints,
            reviewPoints,
            practicePoints,
            challengePoints
        ])
    }

    /// The number of points this user earned through challenges.
    var challengePoints: Int {
        Self.saturatingPointTotal(dailyChallenges.lazy.map(\.score))
    }

    /// The user's current rank number.
    var rankNumber: Int {
        User.rankLevels.firstIndex { $0 > totalPoints }
            ?? (User.rankLevels.count - 1)
    }

    /// How many points the user needs before they rank up, or nil if they are at the maximum rank.
    var pointsUntilNextRank: Int? {
        guard rankNumber < 21 else { return nil }
        return User.rankLevels[rankNumber] - totalPoints
    }

    func hasCompletedChallenge(on date: Date) -> Bool {
        guard let mostRecent = dailyChallenges.first else { return false }
        return mostRecent.date.isSameDay(as: date)
    }

    // MARK: - Methods
    init(now: Date = .now) {
        lastStreakEntry = now
    }

    /// Implement Decodable's initializer in an extension so we don't lose the built-in one: https://www.hackingwithswift.com/example-code/language/how-to-add-a-custom-initializer-to-a-struct-without-losing-its-memberwise-initializer
    ///
    /// NB: This is a custom initializer so we can add new fields with default values in the future. We don't need to create a custom encoder because we always save all coding keys.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        streakDays = try container.decodeIfPresent(Int.self, forKey: .streakDays) ?? 1
        bestStreak = try container.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 1
        lastStreakEntry = try container.decodeIfPresent(Date.self, forKey: .lastStreakEntry) ?? Date()

        learnedSections = try container.decodeIfPresent(Set<String>.self, forKey: .learnedSections) ?? []
        reviewedSections = try container.decodeIfPresent(Set<String>.self, forKey: .reviewedSections) ?? []
        practiceSessions = try container.decodeIfPresent(CountedSet<String>.self, forKey: .practiceSessions) ?? CountedSet<String>()
        practicePoints = try container.decodeIfPresent(Int.self, forKey: .practicePoints) ?? 0
        dailyChallenges = try container.decodeIfPresent([ChallengeResult].self, forKey: .dailyChallenges) ?? []

        latestNewsArticle = try container.decodeIfPresent(Int.self, forKey: .latestNewsArticle) ?? 0
        articlesRead = try container.decodeIfPresent(Set<URL>.self, forKey: .articlesRead) ?? []

        theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? "Light"

    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(streakDays, forKey: .streakDays)
        try container.encode(bestStreak, forKey: .bestStreak)
        try container.encode(lastStreakEntry, forKey: .lastStreakEntry)

        try container.encode(learnedSections, forKey: .learnedSections)
        try container.encode(reviewedSections, forKey: .reviewedSections)
        try container.encode(practiceSessions, forKey: .practiceSessions)
        try container.encode(practicePoints, forKey: .practicePoints)
        try container.encode(dailyChallenges, forKey: .dailyChallenges)

        try container.encode(latestNewsArticle, forKey: .latestNewsArticle)
        try container.encode(articlesRead, forKey: .articlesRead)

        try container.encode(theme, forKey: .theme)
    }

    /// Triggered when the user has finished learning
    /// one topic.
    func learnedSection(_ topic: String) {
        learnedSections.insert(topic)
        statusChanged()
    }

    /// Triggered when the user has finished revising
    /// on topic.
    func reviewedSection(_ topic: String) {
        reviewedSections.insert(topic)

        // if they reviewed something it means they also learned it
        learnedSections.insert(topic)

        statusChanged()
    }

    /// Triggered when the user has completed any practice session
    func completedPractice(_ type: String, score: Int) {
        practiceSessions.insert(type)
        practicePoints = Self.saturatingPointTotal([practicePoints, score])
        statusChanged()
    }

    /// Triggered when the user completes a daily challenge.
    /// They score points for each correct answer.
    /// Challenges are inserted at the start of the array so that
    /// most recently completed are shown first.
    func completedChallenge(score: Int, at date: Date = .now) {
        let result = ChallengeResult(date: date, score: score)
        dailyChallenges.insert(result, at: 0)
        statusChanged()
    }

    func removeChallenge(id: ChallengeResult.ID) {
        guard let index = dailyChallenges.firstIndex(where: { $0.id == id }) else { return }
        dailyChallenges.remove(at: index)
        statusChanged()
    }

    /// Triggered when the user reads any news story.
    func readNewsStory(forURL url: URL) {
        articlesRead.insert(url)
        statusChanged()
    }

    /// Triggered when checking if the user read a news story.
    func hasReadNewsStory(forURL url: URL) -> Bool {
        return articlesRead.contains(url)
    }

    /// Updates the user's streak relative to a supplied date.
    func reconcileStreak(at today: Date) {
        guard lastStreakEntry.isSameDay(as: today) == false else { return }

        if today > lastStreakEntry {
            let elapsedDays = lastStreakEntry.days(between: today)

            if elapsedDays == 1 {
                lastStreakEntry = today
                let (nextStreak, overflowed) = streakDays.addingReportingOverflow(1)
                streakDays = overflowed ? .max : nextStreak
                bestStreak = max(bestStreak, streakDays)
            } else {
                streakDays = 1
                lastStreakEntry = today
            }
        } else {
            let elapsedDays = today.days(between: lastStreakEntry)

            if elapsedDays == 1 {
                lastStreakEntry = today
                bestStreak = max(bestStreak, streakDays)
            } else {
                streakDays = 1
                lastStreakEntry = today
            }
        }

        save()
    }

    /// Persists user changes. Observation updates the SwiftUI hierarchy directly.
    private func statusChanged() {
        // Progress changes should be durable before the next interaction.
        save()
    }

    /// Returns how many points the user has earned for a specific chapter in the book.
    func ratingForSection(_ section: String) -> Int {
        var basePoints = 0

        if learnedSections.contains(section) {
            basePoints += User.pointsForLearning
        }

        if reviewedSections.contains(section) {
            basePoints += User.pointsForReviewing
        }

        return basePoints
    }

    /// Returns true if the user has learned a specific chapter of the book.
    func hasLearned(_ section: String) -> Bool {
        return learnedSections.contains(section)
    }

    /// Returns true if the user has reviewed a specific chapter of the book.
    func hasReviewed(_ section: String) -> Bool {
        return reviewedSections.contains(section)
    }

    /// Tracks the highest-numbered article the user has seen – i.e., was present when they visited the News tab. This doesn't mean they have *read* that article.
    func seenUpToArticle(_ articleID: Int) {
        latestNewsArticle = max(latestNewsArticle, articleID)
        statusChanged()
    }

    /// Reset user progress.
    func resetProgress() {
        dailyChallenges.removeAll()
        practiceSessions = CountedSet<String>()
        practicePoints = 0
        reviewedSections.removeAll()
        learnedSections.removeAll()
        statusChanged()
    }

    /// Updates this observable instance without breaking references held by active sessions.
    func replaceProgress(with source: User) {
        (streakDays, bestStreak, lastStreakEntry) = (source.streakDays, source.bestStreak, source.lastStreakEntry)
        (learnedSections, reviewedSections) = (source.learnedSections, source.reviewedSections)
        (practiceSessions, practicePoints) = (source.practiceSessions, source.practicePoints)
        dailyChallenges = source.dailyChallenges
        (latestNewsArticle, articlesRead, theme) = (source.latestNewsArticle, source.articlesRead, source.theme)
    }

    static func saturatingPointTotal<S: Sequence>(_ values: S) -> Int where S.Element == Int {
        values.reduce(0) { partial, value in
            let nonnegativeValue = max(0, value)
            let (result, overflowed) = partial.addingReportingOverflow(nonnegativeValue)
            return overflowed ? .max : result
        }
    }
}
