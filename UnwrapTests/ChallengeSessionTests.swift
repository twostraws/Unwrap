//
//  ChallengeSessionTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@Suite("Challenge session")
struct ChallengeSessionTests {
    @Test("Titles name the current activity and its position out of ten")
    func titles() {
        let activityNames: [PracticeKind: String] = [
            .freeCoding: "Free Coding",
            .predictTheOutput: "Predict the Output",
            .rearrangeTheLines: "Rearrange the Lines",
            .spotTheError: "Spot the Error",
            .tapToCode: "Tap to Code",
            .typeChecker: "Type Practice"
        ]
        let session = ChallengeSession(random: SeededRandomSource(seed: 4))

        for questionNumber in 1...ChallengeSession.questionCount {
            let activityName = activityNames[session.currentKind, default: "Missing name"]

            #expect(session.currentKind == session.questionKinds[questionNumber - 1])
            #expect(session.title == "\(activityName) (\(questionNumber)/10)")

            session.submit(wasCorrect: false)
            session.continueAfterFeedback()
        }
    }

    @Test("Each question is answered once, then its feedback must be dismissed")
    func answerFeedbackCycle() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 5))

        // There's no feedback to dismiss before an answer arrives.
        session.continueAfterFeedback()
        #expect(session.questionNumber == 1)
        #expect(session.phase == .answering)

        session.submit(wasCorrect: true)
        #expect(session.score == ChallengeSession.pointsPerCorrectAnswer)
        #expect(session.phase == .feedback)
        #expect(session.questionNumber == 1)

        // A second answer to the same question can't score again.
        session.submit(wasCorrect: true)
        #expect(session.score == ChallengeSession.pointsPerCorrectAnswer)

        session.continueAfterFeedback()
        #expect(session.questionNumber == 2)
        #expect(session.phase == .answering)

        session.submit(wasCorrect: false)
        #expect(session.score == ChallengeSession.pointsPerCorrectAnswer)
        #expect(session.phase == .feedback)
    }

    @Test("A question can't be skipped once it has been answered")
    func skippingDuringFeedback() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 6))
        session.submit(wasCorrect: true)

        #expect(session.skip() == false)
        #expect(session.remainingSkips == ChallengeSession.maximumSkips)
        #expect(session.questionNumber == 1)
        #expect(session.phase == .feedback)
    }

    @Test("Skipping the final question completes the challenge without scoring it")
    func skippingFinalQuestion() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 7))

        for _ in 1..<ChallengeSession.questionCount {
            session.submit(wasCorrect: true)
            session.continueAfterFeedback()
        }

        #expect(session.questionNumber == ChallengeSession.questionCount)
        #expect(session.phase == .answering)
        #expect(session.skip())
        #expect(session.phase == .completed)
        #expect(session.score == 450)
        #expect(session.remainingSkips == 2)
    }

    @Test("A completed challenge ignores further answers and skips")
    func completedSessionIsFinal() {
        let session = ChallengeSession(random: SeededRandomSource(seed: 8))

        for _ in 1...ChallengeSession.questionCount {
            session.submit(wasCorrect: false)
            session.continueAfterFeedback()
        }

        #expect(session.phase == .completed)

        session.submit(wasCorrect: true)
        session.continueAfterFeedback()

        #expect(session.skip() == false)
        #expect(session.phase == .completed)
        #expect(session.score == 0)
        #expect(session.questionNumber == ChallengeSession.questionCount)
        #expect(session.remainingSkips == ChallengeSession.maximumSkips)
    }

    @Test("Every shuffle keeps the same weighted mix of activities", arguments: 0..<20)
    func weightedMix(seed: Int) {
        let session = ChallengeSession(random: SeededRandomSource(seed: UInt64(seed)))
        let counts = Dictionary(grouping: session.questionKinds, by: \.self).mapValues(\.count)

        #expect(counts == [
            .spotTheError: 3,
            .rearrangeTheLines: 2,
            .tapToCode: 2,
            .predictTheOutput: 1,
            .freeCoding: 1,
            .typeChecker: 1
        ])
    }
}
