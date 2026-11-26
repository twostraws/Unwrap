//
//  ChallengesModel.swift
//  Unwrap
//

import Foundation
import Observation

@Observable
final class ChallengesModel {
    private(set) var awardModel: AwardModel?
    private(set) var session: ChallengeSession?
    private(set) var question: PracticeQuestion?
    private(set) var questionError: String?

    private let user: User
    private let now: () -> Date
    private let makeRandomSource: () -> any RandomProviding
    private let questionFactory: PracticeQuestionFactory

    init(
        user: User,
        now: @escaping () -> Date = { .now },
        makeRandomSource: @escaping () -> any RandomProviding = { SystemRandomSource() }
    ) {
        self.user = user
        self.now = now
        self.makeRandomSource = makeRandomSource
        questionFactory = PracticeQuestionFactory(
            user: user,
            random: makeRandomSource()
        )
    }

    var hasCompletedToday: Bool {
        user.hasCompletedChallenge(on: now())
    }

    var todayTitle: String {
        now().formatted
    }

    var history: [ChallengeResult] {
        user.dailyChallenges
    }

    @discardableResult
    func startChallenge() -> Bool {
        guard hasCompletedToday == false, session == nil else { return false }
        session = ChallengeSession(random: makeRandomSource())
        loadQuestion()
        return question != nil
    }

    @discardableResult
    func submit(_ result: PracticeAnswerResult) -> Bool {
        guard question != nil, let session, session.phase == .answering else { return false }
        session.submit(wasCorrect: result.isCorrect)
        return true
    }

    func finishQuestionFeedback() {
        guard let session else { return }
        session.continueAfterFeedback()

        if session.phase == .completed {
            presentCompletionAward()
        } else {
            loadQuestion()
        }
    }

    @discardableResult
    func skipQuestion() -> Bool {
        guard let session, session.skip() else { return false }

        if session.phase == .completed {
            presentCompletionAward()
        } else {
            loadQuestion()
        }

        return true
    }

    func endChallenge() {
        guard session != nil else { return }
        user.completedChallenge(score: 0, at: now())
        abandonChallenge()
    }

    func abandonChallenge() {
        awardModel = nil
        session = nil
        question = nil
    }

    func continueAfterAward() {
        awardModel = nil
        session = nil
        question = nil
    }

    func delete(_ result: ChallengeResult) {
        user.removeChallenge(id: result.id)
    }

    func clearQuestionError() {
        questionError = nil
    }

    private func presentCompletionAward() {
        guard awardModel == nil, let session, session.phase == .completed else { return }
        awardModel = AwardModel.applying(
            points: session.score,
            reason: .challenge,
            date: now(),
            to: user
        )
        question = nil
    }

    private func loadQuestion() {
        guard let session, session.phase == .answering else {
            question = nil
            return
        }

        do {
            question = try questionFactory.makeQuestion(for: session.currentKind)
            questionError = nil
        } catch {
            awardModel = nil
            self.session = nil
            question = nil
            questionError = error.localizedDescription
        }
    }
}
