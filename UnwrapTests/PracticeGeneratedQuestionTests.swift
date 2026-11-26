//
//  PracticeGeneratedQuestionTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Generated Practice questions", .serialized)
struct PracticeGeneratedQuestionTests {
    @Test("Free Coding accepts every generated canonical pattern", arguments: 0..<100)
    func freeCoding(seed: Int) throws {
        guard case .freeCoding(let state) = try makeQuestion(.freeCoding, seed: seed) else {
            Issue.record("Free Coding factory returned the wrong question kind.")
            return
        }

        #expect(state.prompt.isEmpty == false)
        #expect(state.acceptedAnswers.isEmpty == false)

        for acceptedAnswer in state.acceptedAnswers {
            let representativeAnswer = acceptedAnswer
                .replacing("letvar", with: "var")
                .replacing("optionalreturn", with: "")
            let completeAnswer = state.startingCode.isEmpty
                ? representativeAnswer
                : "\(state.startingCode)\n\(representativeAnswer)"
            let evaluation = FreeCodingEvaluator().evaluate(
                answer: completeAnswer,
                startingCode: state.startingCode,
                acceptedAnswers: [acceptedAnswer]
            )

            #expect(
                evaluation.isCorrect,
                "Seed \(seed) rejected a canonical Free Coding answer: \(representativeAnswer)"
            )
        }
    }

    @Test("Predict the Output accepts its generated answer", arguments: 0..<100)
    func predictOutput(seed: Int) throws {
        guard case .predictOutput(var state) = try makeQuestion(.predictTheOutput, seed: seed) else {
            Issue.record("Predict the Output factory returned the wrong question kind.")
            return
        }

        state.updateAnswer(state.correctOutput)
        let result = state.submit()
        #expect(result == .correct, "Seed \(seed) rejected its generated output.")
        #expect(state.isLocked)
    }

    @Test("Rearrange accepts generated lines with surrounding whitespace", arguments: 0..<100)
    func rearrange(seed: Int) throws {
        guard case .rearrange(let generated) = try makeQuestion(.rearrangeTheLines, seed: seed) else {
            Issue.record("Rearrange the Lines factory returned the wrong question kind.")
            return
        }

        let whitespaceAdjusted = generated.correctLines.map {
            RearrangeQuestionState.Line(id: $0.id, text: "\t\($0.text)  ")
        }
        var state = RearrangeQuestionState(
            prompt: generated.prompt,
            hint: generated.hint,
            correctLines: generated.correctLines,
            lines: whitespaceAdjusted
        )

        let result = state.submit()
        #expect(result == .correct, "Seed \(seed) rejected correctly ordered lines.")
        #expect(state.isLocked)
    }

    @Test("Review accepts its exact generated answer", arguments: 0..<100)
    func review(seed: Int) throws {
        guard case .review(var state) = try makeQuestion(.review, seed: seed) else {
            Issue.record("Review factory returned the wrong question kind.")
            return
        }

        switch state.style {
        case .single:
            let choice = try #require(state.choices.first)
            state.selectTruth(choice.isCorrect)
        case .multiple:
            for choice in state.choices where choice.isCorrect {
                state.toggleChoice(id: choice.id)
            }
        }

        let result = state.submit()
        #expect(result == .correct, "Seed \(seed) rejected the exact Review answer.")
        #expect(state.isLocked)
    }

    @Test("Spot the Error identifies one valid generated line", arguments: 0..<100)
    func spotError(seed: Int) throws {
        guard case .spotError(var state) = try makeQuestion(.spotTheError, seed: seed) else {
            Issue.record("Spot the Error factory returned the wrong question kind.")
            return
        }

        #expect(state.lines.contains(where: { $0.id == state.errorLineID }))
        state.select(lineID: state.errorLineID)
        let result = state.submit()
        #expect(result == .correct, "Seed \(seed) did not identify its generated error line.")
        #expect(state.scrollTargetID == state.errorLineID)
    }

    @Test("Tap to Code contains and accepts every generated token", arguments: 0..<100)
    func tapToCode(seed: Int) throws {
        guard case .tapToCode(let generated) = try makeQuestion(.tapToCode, seed: seed) else {
            Issue.record("Tap to Code factory returned the wrong question kind.")
            return
        }

        #expect(generated.correctTokens.count >= 2)

        var solved = TapToCodeQuestionState(
            prompt: generated.prompt,
            existingCode: generated.existingCode,
            correctTokens: generated.correctTokens,
            usedTokens: generated.correctTokens,
            availableTokens: []
        )
        let result = solved.submit()
        #expect(result == .correct, "Seed \(seed) rejected the canonical token order.")
        #expect(solved.isLocked)
    }

    @Test("Type Checker generates a balanced ten-choice answer set", arguments: 0..<100)
    func typeChecker(seed: Int) throws {
        guard case .typeChecker(let state) = try makeQuestion(.typeChecker, seed: seed) else {
            Issue.record("Type Checker factory returned the wrong question kind.")
            return
        }

        let correctCount = state.choices.count(where: \.isCorrect)
        #expect(state.choices.count == 10, "Seed \(seed) did not generate ten choices.")
        #expect((4...6).contains(correctCount), "Seed \(seed) generated \(correctCount) correct choices.")
        #expect(Set(state.choices.map(\.id)).count == state.choices.count)
    }

    private func makeQuestion(_ kind: PracticeKind, seed: Int) throws -> PracticeQuestion {
        let user = kind == .review ? try User.learningEverything() : User()

        return try PracticeQuestionFactory(
            user: user,
            random: SeededRandomSource(seed: UInt64(seed))
        ).makeQuestion(for: kind)
    }
}
