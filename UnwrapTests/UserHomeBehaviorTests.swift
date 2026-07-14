//
//  UserHomeBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test("Badge progress covers zero, singular, plural, and receiver-specific reading")
    func badgeProgressCopy() throws {
        let practiceBadge = Badge(name: "Practice", description: "", color: "", criterion: "practice", value: "type-practice")
        #expect(User().badgeProgress(practiceBadge).string == "\n\nYou have not practiced with this yet.")
        let onePractice = User()
        onePractice.completedPractice("type-practice", score: 0)
        #expect(onePractice.badgeProgress(practiceBadge).string == "\n\nYou have practiced 1 time!")
        onePractice.completedPractice("type-practice", score: 0)
        #expect(onePractice.badgeProgress(practiceBadge).string == "\n\nYou have practiced 2 times!")

        let challengeBadge = Badge(name: "Challenge", description: "", color: "", criterion: "challenge", value: "5")
        #expect(User().badgeProgress(challengeBadge).string == "\n\nYou have not completed any challenges yet.")
        let challenges = User()
        challenges.dailyChallenges = makeChallenges(count: 1)
        #expect(challenges.badgeProgress(challengeBadge).string == "\n\nYou have completed 1 challenge!")
        challenges.dailyChallenges = makeChallenges(count: 2)
        #expect(challenges.badgeProgress(challengeBadge).string == "\n\nYou have completed 2 challenges!")

        let newsBadge = Badge(name: "News", description: "", color: "", criterion: "news", value: "20")
        #expect(User().badgeProgress(newsBadge).string == "\n\nYou have not read any news articles yet.")
        let news = User()
        news.articlesRead = makeArticleURLs(count: 1)
        #expect(news.badgeProgress(newsBadge).string == "\n\nYou have read 1 news article!")
        news.articlesRead = makeArticleURLs(count: 2)
        #expect(news.badgeProgress(newsBadge).string == "\n\nYou have read 2 news articles!")

        let shareBadge = Badge(name: "Share", description: "", color: "", criterion: "share", value: "1")
        #expect(User().badgeProgress(shareBadge).string == "\n\nYou have not shared your score yet.")
        let shares = User()
        shares.scoreShareCount = 1
        #expect(shares.badgeProgress(shareBadge).string == "\n\nYou have shared your score 1 time!")
        shares.scoreShareCount = 2
        #expect(shares.badgeProgress(shareBadge).string == "\n\nYou have shared your score 2 times!")

        let streakBadge = Badge(name: "Streak", description: "", color: "", criterion: "streak", value: "5")
        #expect(User().badgeProgress(streakBadge).string == "\n\nYou have only played one day.")
        let streak = User()
        streak.bestStreak = 2
        #expect(streak.badgeProgress(streakBadge).string == "\n\nYour best streak is 2 days!")

        let chapter = try #require(Unwrap.chapters.first(where: { $0.sections.isEmpty == false }))
        let firstSection = try #require(chapter.sections.first)
        let readBadge = Badge(
            name: "Read",
            description: "",
            color: "",
            criterion: "read",
            value: chapter.name.bundleName
        )
        let receiver = User()
        receiver.reviewedSection(firstSection.bundleName)
        let global = User()

        withCurrentUser(global) {
            #expect(
                receiver.badgeProgress(readBadge).string
                    == "\n\nYou have completed 1 out of \(chapter.sections.count) chapters!"
            )
        }
    }

    @Test("Home sections expose current values and refresh after user changes")
    func homeSections() throws {
        let user = User()
        user.learnedSection("learned")
        user.reviewedSection("reviewed")
        user.completedPractice("type-practice", score: 40)
        user.dailyChallenges = [ChallengeResult(date: Date(), score: 75)]
        user.streakDays = 3
        user.bestStreak = 7

        try withCurrentUser(user) {
            let dataSource = HomeDataSource()
            #expect(dataSource.sections.map(\.type) == [.status, .score, .stats, .streak, .badges])
            #expect(dataSource.sections.map(\.title) == [nil, "POINTS", "STATS", "STREAK", "BADGES"])
            #expect(dataSource.sections.map { $0.items.count } == [2, 5, 3, 2, dataSource.badges.count])

            let scoreItems = dataSource.sections[1].items
            let learning = try #require(stat(from: scoreItems[0]))
            #expect(learning.text == "Learning Points")
            #expect(learning.detail == user.learnPoints.formatted)
            #expect(learning.accessibility == "200 points from learning")

            let review = try #require(stat(from: scoreItems[1]))
            #expect(review.detail == user.reviewPoints.formatted)
            #expect(review.accessibility == "100 points from reviews")

            let practice = try #require(stat(from: scoreItems[2]))
            #expect(practice.detail == "40")
            #expect(practice.accessibility == "40 points from practicing")

            let challenge = try #require(stat(from: scoreItems[3]))
            #expect(challenge.detail == "75")
            #expect(challenge.accessibility == "75 points from challenges")
            #expect(isShare(scoreItems[4]))

            let statsItems = dataSource.sections[2].items
            let level = try #require(stat(from: statsItems[0]))
            #expect(level.detail == "2/21")
            #expect(level.accessibility == "You are level 2 of 21.")
            let points = try #require(stat(from: statsItems[1]))
            #expect(points.detail == "85")
            #expect(points.accessibility == "You need 85 more points to reach the next level.")
            let dailyChallenges = try #require(stat(from: statsItems[2]))
            #expect(dailyChallenges.detail == "1")
            #expect(dailyChallenges.accessibility == "1 daily challenge completed.")

            let streakItems = dataSource.sections[3].items
            let currentStreak = try #require(stat(from: streakItems[0]))
            #expect(currentStreak.detail == "3")
            #expect(currentStreak.accessibility == "Your streak count is 3")
            #expect(streakItems[0].name == "Streak Reminder")
            let bestStreak = try #require(stat(from: streakItems[1]))
            #expect(bestStreak.detail == "7")
            #expect(bestStreak.accessibility == "Your best streak count is 7")

            user.completedPractice("type-practice", score: 5)
            user.dailyChallenges.append(ChallengeResult(date: Date(), score: 25))
            dataSource.updateSections()
            let refreshedPractice = try #require(stat(from: dataSource.sections[1].items[2]))
            #expect(refreshedPractice.detail == "45")
            let refreshedChallenges = try #require(stat(from: dataSource.sections[2].items[2]))
            #expect(refreshedChallenges.detail == "2")
            #expect(refreshedChallenges.accessibility == "2 daily challenges completed.")
            #expect(dataSource.sections.count == 5)
        }
    }

    @Test("Home reports the maximum rank without a next-level requirement")
    func maximumRankHomeStats() throws {
        let user = User()
        user.practicePoints = User.rankLevels[User.rankLevels.count - 2]

        try withCurrentUser(user) {
            let stats = HomeDataSource().sections[2].items
            let level = try #require(stat(from: stats[0]))
            #expect(level.detail == "21/21")
            let points = try #require(stat(from: stats[1]))
            #expect(points.detail == "N/A")
            #expect(points.accessibility == "You are at the maximum level.")
        }
    }

    private struct HomeStatValues {
        let text: String
        let detail: String
        let accessibility: String
    }

    private func stat(from item: HomeItem) -> HomeStatValues? {
        guard case let .stat(text, detail, accessibility) = item.type else {
            return nil
        }

        return HomeStatValues(text: text, detail: detail, accessibility: accessibility)
    }

    private func isShare(_ item: HomeItem) -> Bool {
        if case .share = item.type {
            return true
        } else {
            return false
        }
    }

    private func withCurrentUser<T>(_ user: User, operation: () throws -> T) rethrows -> T {
        let previousUser: User? = User.current
        User.current = user
        defer { User.current = previousUser }
        return try operation()
    }
}
