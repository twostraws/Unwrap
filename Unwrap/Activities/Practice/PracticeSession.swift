//
//  PracticeSession.swift
//  Unwrap
//

import Observation

@Observable
final class PracticeSession {
    enum Phase: Equatable {
        case answering
        case submitted
        case completed
    }

    static let questionCount = 10

    let kind: PracticeKind

    private(set) var questionNumber = 1
    private(set) var score = 0
    private(set) var currentQuestion: PracticeQuestion
    private(set) var phase = Phase.answering
    private(set) var awardModel: AwardModel?

    private let makeQuestion: () throws -> PracticeQuestion
    private let user: User
    #if DEBUG
    private var isDebugPreview = false

    /// Unlocks all question content without changing the learner's progress or saving awards.
    static func unlockedForDebug(
        kind: PracticeKind,
        user: User,
        randomSource: any RandomProviding
    ) throws -> PracticeSession {
        let factory = PracticeQuestionFactory.unlockedForDebug(user: user, random: randomSource)
        let session = try PracticeSession(kind: kind, user: user) {
            try factory.makeQuestion(for: kind)
        }
        session.isDebugPreview = true
        return session
    }
    #endif

    var canRequestHint: Bool {
        phase == .answering
    }

    init(
        kind: PracticeKind,
        user: User,
        makeQuestion: @escaping () throws -> PracticeQuestion
    ) throws {
        self.kind = kind
        self.user = user
        self.makeQuestion = makeQuestion
        currentQuestion = try makeQuestion()
    }

    convenience init(
        kind: PracticeKind,
        user: User,
        randomSource: any RandomProviding
    ) throws {
        let factory = PracticeQuestionFactory(
            user: user,
            random: randomSource
        )
        try self.init(
            kind: kind,
            user: user,
            makeQuestion: { try factory.makeQuestion(for: kind) }
        )
    }

    @discardableResult
    func submit(_ result: PracticeAnswerResult) -> Bool {
        guard phase == .answering else { return false }

        switch result {
        case .correct:
            score += User.pointsForPracticing
        case .incorrect:
            break
        case .retryableIncorrect:
            return false
        }

        phase = .submitted
        return true
    }

    func requestHint() -> String? {
        guard canRequestHint else { return nil }
        return currentQuestion.hint
    }

    @discardableResult
    func continueSession() throws -> Bool {
        guard phase == .submitted else { return false }

        if questionNumber == Self.questionCount {
            awardModel = makeAward()
            phase = .completed
            return true
        }

        let nextQuestion = try makeQuestion()
        questionNumber += 1
        currentQuestion = nextQuestion
        phase = .answering
        return true
    }

    private func makeAward() -> AwardModel {
        #if DEBUG
        if isDebugPreview {
            return AwardModel.previewingForDebug(points: score, user: user)
        }
        #endif
        return AwardModel.applying(
            points: score,
            reason: .practice(kind: kind.id),
            to: user
        )
    }
}
