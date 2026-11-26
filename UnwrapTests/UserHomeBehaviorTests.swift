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
        let practiceBadge = Badge(name: "Practice", description: "", color: "", symbolName: "star.fill", criterion: "practice", value: "type-practice")
        #expect(User().badgeProgress(practiceBadge) == "\n\nYou have not practiced with this yet.")
        let onePractice = User()
        onePractice.completedPractice("type-practice", score: 0)
        #expect(onePractice.badgeProgress(practiceBadge) == "\n\nYou have practiced 1 time!")
        onePractice.completedPractice("type-practice", score: 0)
        #expect(onePractice.badgeProgress(practiceBadge) == "\n\nYou have practiced 2 times!")

        let challengeBadge = Badge(name: "Challenge", description: "", color: "", symbolName: "star.fill", criterion: "challenge", value: "5")
        #expect(User().badgeProgress(challengeBadge) == "\n\nYou have not completed any challenges yet.")
        let challenges = User()
        challenges.dailyChallenges = makeChallenges(count: 1)
        #expect(challenges.badgeProgress(challengeBadge) == "\n\nYou have completed 1 challenge!")
        challenges.dailyChallenges = makeChallenges(count: 2)
        #expect(challenges.badgeProgress(challengeBadge) == "\n\nYou have completed 2 challenges!")

        let newsBadge = Badge(name: "News", description: "", color: "", symbolName: "star.fill", criterion: "news", value: "20")
        #expect(User().badgeProgress(newsBadge) == "\n\nYou have not read any news articles yet.")
        let news = User()
        news.articlesRead = makeArticleURLs(count: 1)
        #expect(news.badgeProgress(newsBadge) == "\n\nYou have read 1 news article!")
        news.articlesRead = makeArticleURLs(count: 2)
        #expect(news.badgeProgress(newsBadge) == "\n\nYou have read 2 news articles!")

        let streakBadge = Badge(name: "Streak", description: "", color: "", symbolName: "star.fill", criterion: "streak", value: "5")
        #expect(User().badgeProgress(streakBadge) == "\n\nYou have only played one day.")
        let streak = User()
        streak.bestStreak = 2
        #expect(streak.badgeProgress(streakBadge) == "\n\nYour best streak is 2 days!")

        let chapter = try #require(Unwrap.chapters.first(where: { $0.sections.isEmpty == false }))
        let firstSection = try #require(chapter.sections.first)
        let readBadge = Badge(
            name: "Read",
            description: "",
            color: "",
            symbolName: "star.fill",
            criterion: "read",
            value: chapter.name.bundleName
        )
        let receiver = User()
        receiver.reviewedSection(firstSection.bundleName)
        #expect(
            receiver.badgeProgress(readBadge)
                == "\n\nYou have completed 1 out of \(chapter.sections.count) chapters!"
        )
    }
}
