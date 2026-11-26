//
//  PracticeSessionTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Practice session", .serialized)
struct PracticeSessionTests {
    final class FixtureQuestionSource {
        private(set) var callCount = 0

        func makeQuestion() throws -> PracticeQuestion {
            callCount += 1
            return .predictOutput(
                PredictOutputQuestionState(
                    code: "print(\(callCount))",
                    correctOutput: String(callCount)
                )
            )
        }
    }

    @Test("A session starts with its first question ready")
    func initialState() throws {
        let questions = FixtureQuestionSource()
        let session = try PracticeSession(
            kind: .predictTheOutput,
            user: User(),
            makeQuestion: questions.makeQuestion
        )

        #expect(session.questionNumber == 1)
        #expect(session.score == 0)
        #expect(session.phase == .answering)
        #expect(session.awardModel == nil)
        #expect(session.requestHint() == session.currentQuestion.hint)
        #expect(questions.callCount == 1)
    }

    @Test("Only one accepted answer can score each question")
    func acceptedAnswerScoresOnce() throws {
        let session = try makeSession()

        #expect(session.submit(.retryableIncorrect) == false)
        #expect(session.phase == .answering)
        #expect(session.submit(.correct))
        #expect(session.score == User.pointsForPracticing)
        #expect(session.phase == .submitted)
        #expect(session.submit(.correct) == false)
        #expect(session.requestHint() == nil)
    }

    @Test("Continuing advances to one fresh question")
    func continueSession() throws {
        let questions = FixtureQuestionSource()
        let session = try PracticeSession(
            kind: .predictTheOutput,
            user: User(),
            makeQuestion: questions.makeQuestion
        )

        #expect(try session.continueSession() == false)
        #expect(session.submit(.incorrect))
        #expect(try session.continueSession())
        #expect(session.questionNumber == 2)
        #expect(session.phase == .answering)
        #expect(questions.callCount == 2)
        #expect(try session.continueSession() == false)
        #expect(questions.callCount == 2)
    }

    @Test("Completing ten questions awards the earned Practice points once")
    func completionAwardsPoints() throws {
        let questions = FixtureQuestionSource()
        let user = User()
        let session = try PracticeSession(
            kind: .predictTheOutput,
            user: user,
            makeQuestion: questions.makeQuestion
        )

        try complete(session, with: .correct)

        let expectedScore = PracticeSession.questionCount * User.pointsForPracticing
        #expect(session.score == expectedScore)
        #expect(session.phase == .completed)
        #expect(session.awardModel?.earnedPoints == expectedScore)
        #expect(questions.callCount == PracticeSession.questionCount)
        #expect(user.practicePoints == expectedScore)
        #expect(user.practiceSessions.count(for: "predict-the-output") == 1)

        #expect(try session.continueSession() == false)
        #expect(user.practicePoints == expectedScore)
        #expect(user.practiceSessions.count(for: "predict-the-output") == 1)
    }

    @Test("A zero-point completion still records the Practice session")
    func zeroPointCompletion() throws {
        let user = User()
        let session = try makeSession(kind: .tapToCode, user: user)

        try complete(session, with: .incorrect)

        #expect(session.awardModel?.earnedPoints == 0)
        #expect(user.practicePoints == 0)
        #expect(user.practiceSessions.count(for: "tap-to-code") == 1)
    }

    @Test("A session can't begin when its first question fails to load")
    func initialQuestionFailure() {
        // A brand new user hasn't learned anything, so there's nothing to review.
        #expect(throws: PracticeContentError.noReviewSections) {
            try PracticeSession(
                kind: .review,
                user: User(),
                randomSource: SeededRandomSource(seed: 1)
            )
        }
    }

    @Test("A question that fails to load mid-session can be retried without losing progress")
    func midSessionFailure() throws {
        let questions = FixtureQuestionSource()
        var failuresRemaining = 1
        let session = try PracticeSession(kind: .predictTheOutput, user: User()) {
            if questions.callCount == 1, failuresRemaining > 0 {
                failuresRemaining -= 1
                throw PracticeContentError.invalidContent("PredictTheOutput.json")
            }

            return try questions.makeQuestion()
        }
        let firstQuestion = session.currentQuestion

        #expect(session.submit(.correct))
        #expect(throws: PracticeContentError.invalidContent("PredictTheOutput.json")) {
            try session.continueSession()
        }

        #expect(session.questionNumber == 1)
        #expect(session.phase == .submitted)
        #expect(session.score == User.pointsForPracticing)
        #expect(session.currentQuestion == firstQuestion)

        #expect(try session.continueSession())
        #expect(session.questionNumber == 2)
        #expect(session.phase == .answering)
        #expect(session.currentQuestion != firstQuestion)
    }

    @Test("Sessions created from a random source draw bundled questions of their own kind")
    func bundledQuestions() throws {
        let session = try PracticeSession(
            kind: .typeChecker,
            user: User(),
            randomSource: SeededRandomSource(seed: 3)
        )

        guard case .typeChecker(let state) = session.currentQuestion else {
            Issue.record("A Type Checker session should start with a Type Checker question.")
            return
        }

        #expect(session.kind == .typeChecker)
        #expect(session.requestHint() == state.hint)
    }

    @Test("Mixed results score only the correct answers")
    func mixedResults() throws {
        let user = User()
        let session = try makeSession(user: user)

        for questionNumber in 1...PracticeSession.questionCount {
            #expect(session.submit(questionNumber.isMultiple(of: 2) ? .correct : .incorrect))
            #expect(try session.continueSession())
        }

        #expect(session.score == 5 * User.pointsForPracticing)
        #expect(session.awardModel?.startingTotal == 0)
        #expect(session.awardModel?.endingTotal == 5 * User.pointsForPracticing)
        #expect(user.practicePoints == 5 * User.pointsForPracticing)
    }

    #if DEBUG
    @Test("Debug unlocks can complete every activity without changing user progress", arguments: PracticeKind.allCases)
    func debugUnlocksDoNotChangeProgress(kind: PracticeKind) throws {
        let user = User()
        user.practicePoints = 17
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let originalProgress = try encoder.encode(user)
        let session = try PracticeSession.unlockedForDebug(
            kind: kind,
            user: user,
            randomSource: SeededRandomSource(seed: 3)
        )

        try complete(session, with: .correct)

        let earnedPoints = PracticeSession.questionCount * User.pointsForPracticing
        #expect(session.phase == .completed)
        #expect(session.awardModel?.startingTotal == 17)
        #expect(session.awardModel?.endingTotal == 17 + earnedPoints)
        #expect(session.awardModel?.earnedPoints == earnedPoints)
        #expect(try encoder.encode(user) == originalProgress)
        #expect(PracticeKind.allCases.allSatisfy { $0.isUnlocked(for: user) == false })

        // A regular session still uses the real learned sections after a debug session finishes.
        #expect(throws: PracticeContentError.noReviewSections) {
            try PracticeSession(kind: .review, user: user, randomSource: SeededRandomSource(seed: 3))
        }
    }
    #endif

    private func makeSession(
        kind: PracticeKind = .predictTheOutput,
        user: User? = nil
    ) throws -> PracticeSession {
        try PracticeSession(
            kind: kind,
            user: user ?? User(),
            makeQuestion: FixtureQuestionSource().makeQuestion
        )
    }

    private func complete(_ session: PracticeSession, with result: PracticeAnswerResult) throws {
        for questionNumber in 1...PracticeSession.questionCount {
            #expect(session.questionNumber == questionNumber)
            #expect(session.submit(result))
            #expect(try session.continueSession())
        }
    }
}
