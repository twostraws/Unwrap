//
//  ChallengesModelTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Challenges model", .serialized)
struct ChallengesModelTests {
    @Test("A challenge contains the original weighted mix of ten questions")
    func weightedQuestions() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 1))
        let kinds = session.questionKinds

        #expect(kinds.count == 10)
        #expect(kinds.filter { $0 == .spotTheError }.count == 3)
        #expect(kinds.filter { $0 == .rearrangeTheLines }.count == 2)
        #expect(kinds.filter { $0 == .tapToCode }.count == 2)
        #expect(kinds.filter { $0 == .predictTheOutput }.count == 1)
        #expect(kinds.filter { $0 == .freeCoding }.count == 1)
        #expect(kinds.filter { $0 == .typeChecker }.count == 1)
        #expect(kinds.contains(.review) == false)
    }

    @Test("Ten correct answers award fifty points each")
    func completionAward() throws {
        let now = Date(timeIntervalSince1970: 20_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.startChallenge())
        let session = try #require(model.session)

        for questionNumber in 1...ChallengeSession.questionCount {
            #expect(session.questionNumber == questionNumber)
            #expect(model.question != nil)
            #expect(model.submit(.correct))
            #expect(session.score == questionNumber * ChallengeSession.pointsPerCorrectAnswer)
            model.finishQuestionFeedback()
        }

        #expect(session.phase == .completed)
        #expect(session.score == 500)
        #expect(model.awardModel?.earnedPoints == 500)
        #expect(user.challengePoints == 500)
        #expect(user.dailyChallenges == [ChallengeResult(date: now, score: 500)])
    }

    @Test("Exactly three questions may be skipped")
    func skipLimit() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 2))

        #expect(session.skip())
        #expect(session.skip())
        #expect(session.skip())
        #expect(session.remainingSkips == 0)
        #expect(session.questionNumber == 4)
        #expect(session.skip() == false)
        #expect(session.questionNumber == 4)
        #expect(session.score == 0)
    }

    @Test("Ending a challenge records a zero score")
    func endingChallenge() throws {
        let now = Date(timeIntervalSince1970: 40_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.startChallenge())
        #expect(model.submit(.correct))
        let session = try #require(model.session)
        #expect(session.score == 50)

        model.endChallenge()

        #expect(model.session == nil)
        #expect(model.question == nil)
        #expect(model.awardModel == nil)
        #expect(user.dailyChallenges == [ChallengeResult(date: now, score: 0)])
        #expect(model.hasCompletedToday)
    }

    @Test("Deleting today's result unlocks another attempt")
    func deletionUnlocksChallenge() {
        let now = Date(timeIntervalSince1970: 50_000)
        let result = ChallengeResult(date: now, score: 100)
        let user = User(now: now)
        user.dailyChallenges = [result]
        let model = makeModel(user: user, now: now)

        #expect(model.hasCompletedToday)
        #expect(model.startChallenge() == false)

        model.delete(result)

        #expect(model.history.isEmpty)
        #expect(model.hasCompletedToday == false)
        #expect(model.startChallenge())
    }

    @Test("Challenge results use the original sharing copy")
    func shareText() throws {
        // Midday in the device's own calendar, so the formatted day can't shift with the time zone.
        let components = DateComponents(year: 2019, month: 2, day: 28, hour: 12)
        let date = try #require(Calendar.current.date(from: components))
        let shareText = ChallengeResult(date: date, score: 350).shareText

        #expect(shareText.hasPrefix("I scored 350 in Unwrap's daily challenge for "))
        #expect(shareText.contains("28"))
        #expect(shareText.contains("2019"))
        #expect(
            shareText.hasSuffix(
                ". Download it here: https://apps.apple.com/app/id1440611372 (via @twostraws)"
            )
        )
    }

    @Test("Nothing can be answered, skipped, or ended before a challenge starts")
    func inactiveModel() {
        let now = Date(timeIntervalSince1970: 70_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.submit(.correct) == false)
        #expect(model.skipQuestion() == false)
        model.finishQuestionFeedback()
        model.endChallenge()

        #expect(model.session == nil)
        #expect(model.question == nil)
        #expect(model.awardModel == nil)
        #expect(user.dailyChallenges.isEmpty)
        #expect(model.hasCompletedToday == false)
    }

    @Test("Only one challenge can be in progress at a time")
    func singleActiveChallenge() throws {
        let now = Date(timeIntervalSince1970: 80_000)
        let model = makeModel(user: User(now: now), now: now)

        #expect(model.startChallenge())
        let session = try #require(model.session)

        #expect(model.startChallenge() == false)
        #expect(model.session === session)
    }

    @Test("Each question accepts a single answer")
    func singleAnswerPerQuestion() throws {
        let now = Date(timeIntervalSince1970: 90_000)
        let model = makeModel(user: User(now: now), now: now)

        #expect(model.startChallenge())
        #expect(model.submit(.incorrect))
        #expect(model.submit(.correct) == false)

        let session = try #require(model.session)
        #expect(session.score == 0)
        #expect(session.questionNumber == 1)
    }

    @Test("Skipping moves to a fresh question until the three skips are used")
    func skippingQuestions() throws {
        let now = Date(timeIntervalSince1970: 100_000)
        let model = makeModel(user: User(now: now), now: now)

        #expect(model.startChallenge())
        let session = try #require(model.session)

        for skipNumber in 1...ChallengeSession.maximumSkips {
            #expect(model.skipQuestion())
            #expect(session.questionNumber == skipNumber + 1)
            #expect(model.question != nil)
        }

        #expect(model.skipQuestion() == false)
        #expect(session.questionNumber == ChallengeSession.maximumSkips + 1)
        #expect(session.score == 0)
    }

    @Test("Skipping the last question still finishes the challenge and awards the score so far")
    func skippingLastQuestion() throws {
        let now = Date(timeIntervalSince1970: 110_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.startChallenge())

        for _ in 1..<ChallengeSession.questionCount {
            #expect(model.submit(.correct))
            model.finishQuestionFeedback()
        }

        #expect(model.awardModel == nil)
        #expect(model.skipQuestion())

        #expect(model.awardModel?.earnedPoints == 450)
        #expect(model.question == nil)
        #expect(user.dailyChallenges == [ChallengeResult(date: now, score: 450)])
    }

    @Test("Abandoning a challenge records nothing, so it can be started again")
    func abandoningChallenge() {
        let now = Date(timeIntervalSince1970: 120_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.startChallenge())
        #expect(model.submit(.correct))
        model.abandonChallenge()

        #expect(model.session == nil)
        #expect(model.question == nil)
        #expect(user.dailyChallenges.isEmpty)
        #expect(model.hasCompletedToday == false)
        #expect(model.startChallenge())
    }

    @Test("Dismissing the award leaves today's challenge finished and locked")
    func dismissingAward() {
        let now = Date(timeIntervalSince1970: 130_000)
        let user = User(now: now)
        let model = makeModel(user: user, now: now)

        #expect(model.startChallenge())

        for _ in 1...ChallengeSession.questionCount {
            #expect(model.submit(.incorrect))
            model.finishQuestionFeedback()
        }

        #expect(model.awardModel?.earnedPoints == 0)
        model.continueAfterAward()

        #expect(model.awardModel == nil)
        #expect(model.session == nil)
        #expect(model.question == nil)
        #expect(user.dailyChallenges.count == 1)
        #expect(model.hasCompletedToday)
        #expect(model.startChallenge() == false)
    }

    @Test("A result from yesterday doesn't block today's challenge")
    func yesterdayDoesNotBlockToday() throws {
        let today = try #require(
            Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 9))
        )
        let yesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: today))
        let user = User(now: today)
        user.completedChallenge(score: 200, at: yesterday)
        let model = makeModel(user: user, now: today)

        #expect(model.history.count == 1)
        #expect(model.hasCompletedToday == false)
        #expect(model.startChallenge())
    }

    private func makeModel(user: User, now: Date) -> ChallengesModel {
        ChallengesModel(
            user: user,
            now: { now },
            makeRandomSource: { SeededRandomSource(seed: 3) }
        )
    }
}
