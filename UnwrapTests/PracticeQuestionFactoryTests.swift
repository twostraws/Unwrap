//
//  PracticeQuestionFactoryTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Practice question factory", .serialized)
struct PracticeQuestionFactoryTests {
    @Test("Seeded factories produce identical matching question kinds", arguments: 0..<50)
    func seededFactoriesAreDeterministic(seed: Int) throws {
        let user = try User.learningEverything()

        for kind in PracticeKind.allCases {
            let firstFactory = PracticeQuestionFactory(
                user: user,
                random: SeededRandomSource(seed: UInt64(seed))
            )
            let secondFactory = PracticeQuestionFactory(
                user: user,
                random: SeededRandomSource(seed: UInt64(seed))
            )

            let firstQuestion = try firstFactory.makeQuestion(for: kind)
            let secondQuestion = try secondFactory.makeQuestion(for: kind)
            #expect(firstQuestion == secondQuestion)
            #expect(question(firstQuestion, matches: kind))
        }
    }

    @Test("Seeded generated questions resolve all content placeholders", arguments: 0..<100)
    func generatedQuestionsResolvePlaceholders(seed: Int) throws {
        let user = try User.learningEverything()
        let factory = PracticeQuestionFactory(
            user: user,
            random: SeededRandomSource(seed: UInt64(seed))
        )
        let unresolvedPattern = try Regex(
            #"RANDOM_|CONSTANT_OR_VARIABLE|TRUE_OR_FALSE|NAME_(?:NATURAL_)?[0-9]|VALUE_[0-9]|OPERATOR_[0-9]|\$\{"#
        )

        let predict = try factory.makeQuestion(for: .predictTheOutput)
        let tap = try factory.makeQuestion(for: .tapToCode)

        guard case .predictOutput(let predictState) = predict,
              case .tapToCode(let tapState) = tap else {
            Issue.record("Factories returned the wrong question type.")
            return
        }

        #expect(predictState.code.firstMatch(of: unresolvedPattern) == nil)
        #expect(predictState.correctOutput.firstMatch(of: unresolvedPattern) == nil)
        #expect(tapState.prompt.firstMatch(of: unresolvedPattern) == nil)
        #expect(tapState.existingCode.firstMatch(of: unresolvedPattern) == nil)
        #expect(tapState.correctTokens.allSatisfy { $0.text.firstMatch(of: unresolvedPattern) == nil })
    }

    @Test("Review factory requires at least one completed Learn section")
    func reviewRequiresLearnedContent() throws {
        let factory = PracticeQuestionFactory(
            user: User(),
            random: SeededRandomSource(seed: 0)
        )

        do {
            _ = try factory.makeQuestion(for: .review)
            Issue.record("A fresh user should not receive a Review question.")
        } catch let error as PracticeContentError {
            #expect(error == .noReviewSections)
        }
    }

    @Test("Every generated question carries a prompt and a hint", arguments: PracticeKind.allCases)
    func promptsAndHints(kind: PracticeKind) throws {
        let user = try User.learningEverything()

        for seed in 0..<20 {
            let question = try PracticeQuestionFactory(
                user: user,
                random: SeededRandomSource(seed: UInt64(seed))
            ).makeQuestion(for: kind)

            #expect(question.prompt.isEmpty == false, "Seed \(seed) produced \(kind) with no prompt.")
            #expect(question.hint.isEmpty == false, "Seed \(seed) produced \(kind) with no hint.")
        }
    }

    @Test("Review questions come only from sections the user has completed")
    func reviewUsesCompletedSections() throws {
        let user = try User.learning(["variables"])
        let expected = try Bundle.main.decode(ReviewContent.self, from: "variables.json")
        let knownAnswers = Set((expected.correct + expected.wrong).map(\.text))

        for seed in 0..<25 {
            let question = try PracticeQuestionFactory(
                user: user,
                random: SeededRandomSource(seed: UInt64(seed))
            ).makeQuestion(for: .review)

            guard case .review(let state) = question else {
                Issue.record("Review factory returned the wrong question kind.")
                return
            }

            #expect(state.prompt == expected.question)
            #expect(state.hint == expected.hint)
            #expect(state.choices.isEmpty == false)
            #expect(Set(state.choices.map(\.text)).isSubset(of: knownAnswers))

            for choice in state.choices {
                let isListedAsCorrect = expected.correct.contains { $0.text == choice.text }
                #expect(choice.isCorrect == isListedAsCorrect, "Seed \(seed) mislabelled: \(choice.text)")
            }
        }
    }

    @Test("Missing or empty question banks are reported, not crashed on")
    func brokenContent() {
        let missing = PracticeQuestionFactory(user: User(), random: SeededRandomSource(seed: 1)) { name in
            throw BundleResourceError.missingResource(name)
        }
        let empty = PracticeQuestionFactory(user: User(), random: SeededRandomSource(seed: 1)) { _ in
            Data("[]".utf8)
        }

        #expect(throws: BundleResourceError.missingResource("TapToCode.json")) {
            try missing.makeQuestion(for: .tapToCode)
        }
        #expect(throws: PracticeContentError.emptyContent("FreeCoding.json")) {
            try empty.makeQuestion(for: .freeCoding)
        }
        #expect(throws: PracticeContentError.emptyContent("SpotTheError.json")) {
            try empty.makeQuestion(for: .spotTheError)
        }
    }

    @Test("Content errors explain the problem in words a learner can act on")
    func errorDescriptions() {
        #expect(
            PracticeContentError.noReviewSections.localizedDescription
                == "Complete a Learn section before starting Review practice."
        )
        #expect(
            PracticeContentError.emptyContent("TapToCode.json").localizedDescription
                == "There are no practice questions in TapToCode.json."
        )
        #expect(
            PracticeContentError.invalidContent("TapToCode.json").localizedDescription
                == "The practice content in TapToCode.json is invalid."
        )
    }

    private func question(_ question: PracticeQuestion, matches kind: PracticeKind) -> Bool {
        switch (question, kind) {
        case (.freeCoding, .freeCoding),
             (.predictOutput, .predictTheOutput),
             (.rearrange, .rearrangeTheLines),
             (.review, .review),
             (.spotError, .spotTheError),
             (.tapToCode, .tapToCode),
             (.typeChecker, .typeChecker):
            true
        default:
            false
        }
    }
}
