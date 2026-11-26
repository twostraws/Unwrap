//
//  LearnReviewSessionTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@Suite("Learn review sessions")
struct LearnReviewSessionTests {
    @Test("Single-selection reviews use eight unique answers")
    func singleSelectionSequence() throws {
        var session = ReviewSession(
            content: review(kind: .singleSelection),
            random: SeededRandomSource(seed: 42)
        )

        #expect(session.candidates.count == ReviewSession.singleQuestionCount)
        #expect(Set(session.candidates.map(\.id)).count == ReviewSession.singleQuestionCount)

        for question in 1...ReviewSession.singleQuestionCount {
            let candidate = try #require(session.currentCandidate)
            #expect(session.questionNumber == question)
            #expect(session.canSkip)

            session.answerCurrent(candidate.isCorrect)

            #expect(session.submittedAnswerWasCorrect == true)
            #expect(session.canSkip == false)
            let didComplete = session.advance()
            #expect(didComplete == (question == ReviewSession.singleQuestionCount))
        }
    }

    @Test("Single-selection reviews advance after a wrong answer")
    func wrongSingleSelectionAnswer() throws {
        var session = ReviewSession(
            content: review(kind: .singleSelection),
            random: SeededRandomSource(seed: 7)
        )
        let candidate = try #require(session.currentCandidate)

        session.answerCurrent(candidate.isCorrect == false)

        #expect(session.submittedAnswerWasCorrect == false)
        #expect(session.canSkip == false)
        let didComplete = session.advance()
        #expect(didComplete == false)
        #expect(session.questionNumber == 2)
        #expect(session.isShowingAnswer == false)
        #expect(session.canSkip)
    }

    @Test("Multiple-selection reviews require every correct answer")
    func correctMultipleSelection() {
        var session = ReviewSession(
            content: review(kind: .multipleSelection),
            random: SeededRandomSource(seed: 9)
        )

        let correctCandidates = session.candidates.filter(\.isCorrect)

        for candidate in correctCandidates {
            session.toggleSelection(for: candidate.id)
        }

        session.submitMultipleSelection()

        #expect(session.submittedAnswerWasCorrect == true)
        #expect(session.canSkip == false)
    }

    @Test("Multiple-selection reviews lock choices after checking")
    func incorrectMultipleSelection() throws {
        var session = ReviewSession(
            content: review(kind: .multipleSelection),
            random: SeededRandomSource(seed: 11)
        )
        let correctCandidate = session.candidates.first(where: \.isCorrect)
        let correct = try #require(correctCandidate)
        let wrong = try #require(session.candidates.first { $0.isCorrect == false })

        session.toggleSelection(for: correct.id)
        session.toggleSelection(for: wrong.id)
        session.submitMultipleSelection()

        let submittedIDs = session.selectedCandidateIDs
        session.toggleSelection(for: wrong.id)

        #expect(session.submittedAnswerWasCorrect == false)
        #expect(session.selectedCandidateIDs == submittedIDs)
    }

    private func review(kind: ReviewKind) -> ReviewContent {
        ReviewContent(
            title: "Test Review",
            postscript: "",
            kind: kind,
            question: "Question",
            hint: "Hint",
            correct: (1...6).map {
                ReviewAnswer(text: "Correct \($0)", reason: "Correct reason \($0)")
            },
            wrong: (1...6).map {
                ReviewAnswer(text: "Wrong \($0)", reason: "Wrong reason \($0)")
            },
            syntaxHighlighting: false
        )
    }
}
