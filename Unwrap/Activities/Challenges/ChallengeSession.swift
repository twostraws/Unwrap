//
//  ChallengeSession.swift
//  Unwrap
//

import Observation

@Observable
final class ChallengeSession {
    enum Phase {
        case answering
        case feedback
        case completed
    }

    static let pointsPerCorrectAnswer = 50
    static let maximumSkips = 3
    static let questionCount = 10

    private static let weightedKinds: [PracticeKind] = [
        .spotTheError,
        .spotTheError,
        .spotTheError,
        .rearrangeTheLines,
        .rearrangeTheLines,
        .tapToCode,
        .tapToCode,
        .predictTheOutput,
        .freeCoding,
        .typeChecker
    ]

    let questionKinds: [PracticeKind]

    private(set) var currentIndex = 0
    private(set) var phase = Phase.answering
    private(set) var remainingSkips = maximumSkips
    private(set) var score = 0

    var currentKind: PracticeKind {
        questionKinds[currentIndex]
    }

    var questionNumber: Int {
        currentIndex + 1
    }

    var title: String {
        let activityName = switch currentKind {
        case .freeCoding: "Free Coding"
        case .predictTheOutput: "Predict the Output"
        case .rearrangeTheLines: "Rearrange the Lines"
        case .review: "Review"
        case .spotTheError: "Spot the Error"
        case .tapToCode: "Tap to Code"
        case .typeChecker: "Type Practice"
        }

        return "\(activityName) (\(questionNumber)/\(Self.questionCount))"
    }

    init(random: any RandomProviding) {
        questionKinds = random.shuffled(Self.weightedKinds)
    }

    func submit(wasCorrect: Bool) {
        guard phase == .answering else { return }

        if wasCorrect {
            score += Self.pointsPerCorrectAnswer
        }

        phase = .feedback
    }

    func continueAfterFeedback() {
        guard phase == .feedback else { return }
        advance()
    }

    @discardableResult
    func skip() -> Bool {
        guard phase == .answering, remainingSkips > 0 else { return false }
        remainingSkips -= 1
        advance()
        return true
    }

    private func advance() {
        if questionNumber == Self.questionCount {
            phase = .completed
        } else {
            currentIndex += 1
            phase = .answering
        }
    }
}
