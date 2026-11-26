//
//  UserBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("User core", .serialized)
struct UserCoreTests { }

extension UserCoreTests {
    @Test("New users have the complete expected default state")
    func defaults() {
        let user = User()

        #expect(user.streakDays == 1)
        #expect(user.bestStreak == 1)
        #expect(user.lastStreakEntry.isSameDay(as: Date()))
        #expect(user.learnPoints == 0)
        #expect(user.reviewPoints == 0)
        #expect(user.practiceSessions.isEmpty)
        #expect(user.practicePoints == 0)
        #expect(user.dailyChallenges.isEmpty)
        #expect(user.challengePoints == 0)
        #expect(user.latestNewsArticle == 0)
        #expect(user.articlesRead.isEmpty)
        #expect(user.readNewsCount == 0)
        #expect(user.theme == "Light")
        #expect(user.totalPoints == 0)
        #expect(user.rankNumber == 1)
        #expect(user.pointsUntilNextRank == User.rankLevels[1])
        #expect(user.hasCompletedChallenge(on: .now) == false)
        #expect(user.hasLearned("variables") == false)
        #expect(user.hasReviewed("variables") == false)
    }

    @Test("Learning and reviewing are idempotent and review implies learning")
    func learningAndReviewing() {
        let user = User()

        user.learnedSection("variables")
        user.learnedSection("variables")
        #expect(user.hasLearned("variables"))
        #expect(user.hasReviewed("variables") == false)
        #expect(user.ratingForSection("variables") == User.pointsForLearning)
        #expect(user.learnPoints == User.pointsForLearning)

        user.reviewedSection("variables")
        user.reviewedSection("variables")
        #expect(user.hasReviewed("variables"))
        #expect(user.ratingForSection("variables") == User.pointsForLearning + User.pointsForReviewing)
        #expect(user.learnPoints == User.pointsForLearning)
        #expect(user.reviewPoints == User.pointsForReviewing)

        user.reviewedSection("functions")
        user.learnedSection("functions")
        #expect(user.hasLearned("functions"))
        #expect(user.hasReviewed("functions"))
        #expect(user.learnPoints == User.pointsForLearning * 2)
        #expect(user.reviewPoints == User.pointsForReviewing * 2)
        #expect(user.ratingForSection("unknown") == 0)
    }

    @Test("Practice, challenge, and news aggregate independently")
    func activityAggregation() {
        let user = User()
        let firstArticle = URL(fileURLWithPath: "/news/1")
        let secondArticle = URL(fileURLWithPath: "/news/2")

        user.completedPractice("type-practice", score: 10)
        user.completedPractice("type-practice", score: 15)
        user.completedPractice("free-coding", score: 5)
        #expect(user.practiceSessions.count == 2)
        #expect(user.practiceSessions.count(for: "type-practice") == 2)
        #expect(user.practiceSessions.count(for: "free-coding") == 1)
        #expect(user.practicePoints == 30)

        let today = Date(timeIntervalSince1970: Date.now.timeIntervalSince1970.rounded(.down))
        user.completedChallenge(score: 50, at: today.addingTimeInterval(-86_400))
        user.completedChallenge(score: 75, at: today)
        #expect(user.dailyChallenges.map(\.score) == [75, 50])
        #expect(user.challengePoints == 125)
        #expect(user.hasCompletedChallenge(on: today))

        user.readNewsStory(forURL: firstArticle)
        user.readNewsStory(forURL: firstArticle)
        user.readNewsStory(forURL: secondArticle)
        #expect(user.readNewsCount == 2)
        #expect(user.hasReadNewsStory(forURL: firstArticle))
        #expect(user.hasReadNewsStory(forURL: URL(fileURLWithPath: "/news/3")) == false)

        user.seenUpToArticle(42)
        #expect(user.latestNewsArticle == 42)
        #expect(user.totalPoints == 155)
    }

    @Test("Reset clears earned points while retaining account-wide preferences and history")
    func resetContract() {
        let user = User()
        let article = URL(fileURLWithPath: "/news/retained")

        user.learnedSection("variables")
        user.reviewedSection("functions")
        user.completedPractice("type-practice", score: 40)
        user.completedChallenge(score: 60)
        user.readNewsStory(forURL: article)
        user.seenUpToArticle(99)
        user.streakDays = 8
        user.bestStreak = 12
        user.theme = "Dark"

        #expect(user.totalPoints == 400)
        user.resetProgress()

        #expect(user.totalPoints == 0)
        #expect(user.learnPoints == 0)
        #expect(user.reviewPoints == 0)
        #expect(user.practicePoints == 0)
        #expect(user.practiceSessions.isEmpty)
        #expect(user.dailyChallenges.isEmpty)
        #expect(user.rankNumber == 1)
        #expect(user.hasLearned("variables") == false)
        #expect(user.hasReviewed("functions") == false)

        #expect(user.streakDays == 8)
        #expect(user.bestStreak == 12)
        #expect(user.readNewsCount == 1)
        #expect(user.hasReadNewsStory(forURL: article))
        #expect(user.latestNewsArticle == 99)
        #expect(user.theme == "Dark")
    }

    @Test("Every rank boundary reports consistent rank and points remaining")
    func allRankBoundaries() {
        let levels = User.rankLevels

        for boundaryIndex in 1..<(levels.count - 1) {
            let boundary = levels[boundaryIndex]

            let below = User()
            below.practicePoints = boundary - 1
            #expect(below.rankNumber == boundaryIndex)
            #expect(below.pointsUntilNextRank == 1)

            let exact = User()
            exact.practicePoints = boundary
            #expect(exact.rankNumber == boundaryIndex + 1)

            let above = User()
            above.practicePoints = boundary + 1
            #expect(above.rankNumber == boundaryIndex + 1)

            if boundaryIndex == levels.count - 2 {
                #expect(exact.pointsUntilNextRank == nil)
                #expect(above.pointsUntilNextRank == nil)
            } else {
                let nextBoundary = levels[boundaryIndex + 1]
                #expect(exact.pointsUntilNextRank == nextBoundary - boundary)
                #expect(above.pointsUntilNextRank == nextBoundary - boundary - 1)
            }
        }
    }

    @Test("Extreme persisted point values saturate at maximum rank without overflowing")
    func extremePointValuesAreSafe() {
        let user = User()
        user.practicePoints = .max
        user.dailyChallenges = [ChallengeResult(date: .now, score: .max)]

        #expect(user.challengePoints == .max)
        #expect(user.totalPoints == .max)
        #expect(user.rankNumber == User.rankLevels.count - 1)
        #expect(user.pointsUntilNextRank == nil)
        #expect(RankProgressSnapshot(totalPoints: .max).level == User.rankLevels.count - 1)
        #expect(RankProgressSnapshot(totalPoints: -1).level == 1)

        user.completedPractice("free-coding", score: User.pointsForPracticing)
        #expect(user.practicePoints == .max)
    }

    @Test("Streak updates are deterministic for same, past, gap, and future dates")
    func deterministicStreakUpdates() throws {
        let calendar = Calendar.current
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 13, hour: 12)))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))
        let twoDaysAgo = try #require(calendar.date(byAdding: .day, value: -2, to: today))
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        let twoDaysAhead = try #require(calendar.date(byAdding: .day, value: 2, to: today))

        let sameDay = User()
        sameDay.streakDays = 4
        sameDay.bestStreak = 6
        sameDay.lastStreakEntry = today
        sameDay.reconcileStreak(at: today)
        #expect(sameDay.streakDays == 4)
        #expect(sameDay.bestStreak == 6)
        #expect(sameDay.lastStreakEntry == today)

        let consecutive = User()
        consecutive.streakDays = 4
        consecutive.bestStreak = 4
        consecutive.lastStreakEntry = yesterday
        consecutive.reconcileStreak(at: today)
        #expect(consecutive.streakDays == 5)
        #expect(consecutive.bestStreak == 5)
        #expect(consecutive.lastStreakEntry == today)

        let gap = User()
        gap.streakDays = 4
        gap.bestStreak = 9
        gap.lastStreakEntry = twoDaysAgo
        gap.reconcileStreak(at: today)
        #expect(gap.streakDays == 1)
        #expect(gap.bestStreak == 9)
        #expect(gap.lastStreakEntry == today)

        let oneDayFuture = User()
        oneDayFuture.streakDays = 4
        oneDayFuture.bestStreak = 6
        oneDayFuture.lastStreakEntry = tomorrow
        oneDayFuture.reconcileStreak(at: today)
        #expect(oneDayFuture.streakDays == 4)
        #expect(oneDayFuture.bestStreak == 6)
        #expect(oneDayFuture.lastStreakEntry == today)

        let futureGap = User()
        futureGap.streakDays = 4
        futureGap.bestStreak = 6
        futureGap.lastStreakEntry = twoDaysAhead
        futureGap.reconcileStreak(at: today)
        #expect(futureGap.streakDays == 1)
        #expect(futureGap.bestStreak == 6)
        #expect(futureGap.lastStreakEntry == today)
    }

    @Test("Badge catalog is internally consistent")
    func badgeCatalog() throws {
        let badges = try Bundle.main.decode([Badge].self, from: "Badges.json")
        let allowedCriteria: Set<String> = ["read", "practice", "streak", "challenge", "news"]
        let expectedPracticeValues: Set<String> = [
            "type-practice",
            "spot-the-error",
            "predict-the-output",
            "free-coding",
            "rearrange-the-lines",
            "tap-to-code"
        ]

        #expect(badges.isEmpty == false)
        #expect(Set(badges.map(\.name)).count == badges.count)
        #expect(Set(badges.map(\.criterion)).isSubset(of: allowedCriteria))
        #expect(Set(badges.filter { $0.criterion == "practice" }.map(\.value)) == expectedPracticeValues)

        for badge in badges {
            #expect(badge.name.isEmpty == false)
            #expect(badge.description.isEmpty == false)
            #expect(badge.color.isEmpty == false)

            if badge.criterion == "read" {
                let matchingChapters = Unwrap.chapters.filter { $0.name.bundleName == badge.value }
                #expect(matchingChapters.count == 1)
                #expect(matchingChapters.first?.sections.isEmpty == false)
            } else if badge.criterion != "practice" {
                #expect(Int(badge.value).map { $0 > 0 } == true)
            }
        }
    }

    @Test("Every badge unlocks only at its boundary")
    func badgeBoundaries() throws {
        let badges = try Bundle.main.decode([Badge].self, from: "Badges.json")

        for badge in badges {
            #expect(User().isBadgeEarned(badge) == false)

            switch badge.criterion {
            case "read":
                guard let chapter = Unwrap.chapters.first(where: { $0.name.bundleName == badge.value }) else {
                    Issue.record("Missing chapter for badge \(badge.name)")
                    continue
                }

                let sections = chapter.sections.map(\.bundleName)
                guard let finalSection = sections.last else {
                    Issue.record("Badge chapter \(chapter.name) has no sections")
                    continue
                }

                let user = User()
                for section in sections.dropLast() {
                    user.reviewedSection(section)
                }
                #expect(user.isBadgeEarned(badge) == false)
                user.reviewedSection(finalSection)
                #expect(user.isBadgeEarned(badge))

            case "practice":
                let user = User()
                for _ in 0..<9 {
                    user.completedPractice(badge.value, score: 0)
                }
                #expect(user.isBadgeEarned(badge) == false)
                user.completedPractice(badge.value, score: 0)
                #expect(user.isBadgeEarned(badge))
                user.completedPractice(badge.value, score: 0)
                #expect(user.isBadgeEarned(badge))

            case "streak":
                guard let threshold = Int(badge.value) else {
                    Issue.record("Invalid streak threshold for \(badge.name)")
                    continue
                }
                let user = User()
                user.bestStreak = threshold - 1
                #expect(user.isBadgeEarned(badge) == false)
                user.bestStreak = threshold
                #expect(user.isBadgeEarned(badge))
                user.bestStreak = threshold + 1
                #expect(user.isBadgeEarned(badge))

            case "challenge":
                guard let threshold = Int(badge.value) else {
                    Issue.record("Invalid challenge threshold for \(badge.name)")
                    continue
                }
                let user = User()
                user.dailyChallenges = makeChallenges(count: threshold - 1)
                #expect(user.isBadgeEarned(badge) == false)
                user.dailyChallenges = makeChallenges(count: threshold)
                #expect(user.isBadgeEarned(badge))
                user.dailyChallenges = makeChallenges(count: threshold + 1)
                #expect(user.isBadgeEarned(badge))

            case "news":
                guard let threshold = Int(badge.value) else {
                    Issue.record("Invalid news threshold for \(badge.name)")
                    continue
                }
                let user = User()
                user.articlesRead = makeArticleURLs(count: threshold - 1)
                #expect(user.isBadgeEarned(badge) == false)
                user.articlesRead = makeArticleURLs(count: threshold)
                #expect(user.isBadgeEarned(badge))
                user.articlesRead = makeArticleURLs(count: threshold + 1)
                #expect(user.isBadgeEarned(badge))

            default:
                Issue.record("Unknown badge criterion \(badge.criterion)")
            }
        }
    }

    func makeChallenges(count: Int) -> [ChallengeResult] {
        (0..<count).map { ChallengeResult(date: Date(timeIntervalSince1970: Double($0)), score: $0) }
    }

    func makeArticleURLs(count: Int) -> Set<URL> {
        Set((0..<count).map { URL(fileURLWithPath: "/news/\($0)") })
    }
}
