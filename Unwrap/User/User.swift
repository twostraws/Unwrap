//
//  User.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Sourceful
import UIKit

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

        case scoreShareCount
        case latestNewsArticle
        case articlesRead

        case theme
    }

    // MARK: Stored properties

    /// Tracks app launches over days.
    var streakDays = 1
    var bestStreak = 1
    var lastStreakEntry = Date()

    /// Stores the list of sections the user has learned.
    private var learnedSections = Set<String>()

    /// Stores the list of sections the user has reviewed themselves on.
    private var reviewedSections = Set<String>()

    /// How many times this user has completed each type of practice.
    private var practiceSessions = CountedSet<String>()

    /// The number of points this user earned through practicing.
    var practicePoints = 0

    /// An array of all the days the user has completed a challenge.
    var dailyChallenges = [ChallengeResult]()

    /// The number of times the user has shared their score.
    var scoreShareCount = 0

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

    // MARK: Computed properties

    /// The total number of points for this user.
    var totalPoints: Int {
        return learnPoints + reviewPoints + practicePoints + challengePoints
    }

    /// The number of points this user earned through learning.
    var learnPoints: Int {
        return learnedSections.count * User.pointsForLearning
    }

    /// The number of points this user earned through learning.
    var reviewPoints: Int {
        return reviewedSections.count * User.pointsForReviewing
    }

    /// The number of points this user earned through challenges.
    var challengePoints: Int {
        return dailyChallenges.reduce(0) { $0 + $1.score }
    }

    /// The users current rank number.
    var rankNumber: Int {
        let rank = User.rankLevels.firstIndex { $0 > totalPoints }
        return (rank ?? 1)
    }

    /// How many points the user has earned towards their
    /// next rank.
    var pointsTowardsNextRank: Int {
        return totalPoints - User.rankLevels[rankNumber - 1]
    }

    /// How many points the user needs before they rank up.
    /// Returns nil if they are maxed out.
    var pointsUntilNextRank: Int? {
        guard rankNumber < 21 else { return nil }
        return User.rankLevels[rankNumber] - totalPoints
    }

    /// How far through this user is for their
    /// current rank, where 0.001 (the smallest value) means
    /// "just starting".
    var rankFraction: Double {
        if rankNumber == 21 {
            return 1.0
        } else {
            let pointsForNextRank = User.rankLevels[rankNumber]
            let pointsFromPreviousRank = User.rankLevels[rankNumber - 1]
            let pointsDelta = pointsForNextRank - pointsFromPreviousRank

            let fraction = Double(pointsTowardsNextRank) / Double(pointsDelta)

            // always draw at least a tiny piece of the progress
            return max(fraction, User.smallestRankFraction)
        }
    }

    /// Returns the correct image for the user's rank.
    var rankImage: UIImage {
        return UIImage(bundleName: "Rank Level \(rankNumber)")
    }

    /// Returns true if the user has completed today's challenge, or false otherwise.
    var hasCompletedTodaysChallenge: Bool {
        guard let mostRecent = dailyChallenges.first else { return false }

        return mostRecent.date.isSameDay(as: Date())
    }

    /// Returns an instance of the correct source code theme for the user's current settings.
    var sourceCodeTheme: SourceCodeTheme {
        if theme == "Light" {
            return LightTheme()
        } else {
            return DarkTheme()
        }
    }

    // MARK: Methods
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateStreak), name: .NSCalendarDayChanged, object: nil)
        updateStreak()
    }

    /// Implement Decodable's initializer in an extension so we don't lose the built-in one: https://www.hackingwithswift.com/example-code/language/how-to-add-a-custom-initializer-to-a-struct-without-losing-its-memberwise-initializer
    ///
    /// NB: This is a custom initializer so we can add new fields with default values in the future. We don't need to create a custom encoder because we always save all coding keys.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        streakDays = try container.decode(Int.self, forKey: .streakDays)
        bestStreak = try container.decode(Int.self, forKey: .bestStreak)
        lastStreakEntry = try container.decode(Date.self, forKey: .lastStreakEntry)

        learnedSections = try container.decode(Set<String>.self, forKey: .learnedSections)
        reviewedSections = try container.decode(Set<String>.self, forKey: .reviewedSections)
        practiceSessions = try container.decode(CountedSet<String>.self, forKey: .practiceSessions)
        practicePoints = try container.decode(Int.self, forKey: .practicePoints)
        dailyChallenges = try container.decode([ChallengeResult].self, forKey: .dailyChallenges)

        scoreShareCount = try container.decode(Int.self, forKey: .scoreShareCount)
        latestNewsArticle = try container.decode(Int.self, forKey: .latestNewsArticle)
        articlesRead = try container.decode(Set<URL>.self, forKey: .articlesRead)

        theme = try container.decode(String.self, forKey: .theme)

        NotificationCenter.default.addObserver(self, selector: #selector(updateStreak), name: .NSCalendarDayChanged, object: nil)

        updateStreak()
    }

    /// Triggered by new data coming from iCloud; pass it straight on to statusChanged() so all our UI refreshes.
    func cloudUpdate() {
        cloudStatusChanged()
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
        practicePoints += score
        statusChanged()
    }

    /// Triggered when the user completes a daily challenge.
    /// They score points for each correct answer.
    /// Challenges are inserted at the start of the array so that
    /// most recently completed are shown first.
    func completedChallenge(score: Int) {
        let result = ChallengeResult(date: Date(), score: score)
        dailyChallenges.insert(result, at: 0)
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

    /// Sends an app-wide notification that the user's data has changed somehow, so all listening objects can update.
    private func statusChanged() {
        let notification = Notification(name: .userStatusChanged)

        // Prepare to tell all listeners that the user's status has changed. We don't do this immediately to avoid reading and writing at the same time. Coalescing on name means we can call this multiple times in the same run loop without posting multiple notifications.
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])

        // Write the change out to disk at the next available chance; again, we don't want to do this immediately to avoid reading and writing at the same time.
        DispatchQueue.main.async {
            User.current.save()
        }
    }

    /// Sends an app-wide notification when the user's data has changed via the cloud, so all listening objects can update. This is the same as statusChanged but without the save.
    private func cloudStatusChanged() {
        let notification = Notification(name: .userStatusChanged)

        // Prepare to tell all listeners that the user's status has changed. We don't do this immediately to avoid reading and writing at the same time. Coalescing on name means we can call this multiple times in the same run loop without posting multiple notifications.
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])

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
        latestNewsArticle = articleID
        statusChanged()
    }

    /// Called when the user shared their score.
    func sharedScore() {
        scoreShareCount += 1
        statusChanged()
    }

    /// Returns true if a specific badge has been earned, or false otherwise.
    func isBadgeEarned(_ badge: Badge) -> Bool {
        if badge.criterion == "read" {
            guard var conditionChapter = Unwrap.chapters.first(where: {
                $0.name.bundleName == badge.value

            }) else {
                fatalError("Unknown chapter name for criterion: \(badge.value).")
            }

            return conditionChapter.bundleNameSections.reduce(true) {
                $0 && hasReviewed($1.bundleName)
            }
        } else if badge.criterion == "practice" {
            let practiceBadgeCount = 10
            return practiceSessions.count(for: badge.value) >= practiceBadgeCount
        } else {
            guard let intValue = Int(badge.value) else {
                fatalError("Criterion must have its value specified as an integer: \(badge.criterion).")
            }

            switch badge.criterion {
            case "streak":
                return bestStreak >= intValue

            case "challenge":
                return dailyChallenges.count >= intValue

            case "news":
                return readNewsCount >= intValue

            case "share":
                return scoreShareCount >= intValue

            default:
                fatalError("Unknown badge criterion: \(badge.criterion)")
            }
        }
    }

    /// Called whenever we need to update our streak. This checks whether the streak should be updated, then either carries it out or resets the streak if more than 1 day has passed.
    @objc func updateStreak() {
        let today = Date()
        let elapsedDays: Int
        guard lastStreakEntry.isSameDay(as: today) == false else { return }
        // We want to see if today is more recent than sync'd lastStreakEntry. This will be true if we are first in app during or after a calendar day change. Otherwise, our lastStreakEntry is newer and we need to calculate elapsed days the other way.
        if today > lastStreakEntry {
            elapsedDays = lastStreakEntry.days(between: today)
            if elapsedDays == 1 {
                lastStreakEntry = today
                streakDays += 1
                bestStreak = max(bestStreak, streakDays)
            } else {
                // reset back to 1, because they obviously launched the app today
                streakDays = 1
                lastStreakEntry = today
            }
        } else if today < lastStreakEntry {
            elapsedDays = today.days(between: lastStreakEntry)
            if elapsedDays == 1 {
                lastStreakEntry = today
                // Not going to update streakDays here as the version from iCloud already has the correct value
                bestStreak = max(bestStreak, streakDays)
            } else {
                // reset back to 1, because they obviously launched the app today
                streakDays = 1
                lastStreakEntry = today
            }
        }
        save()
    }

}
