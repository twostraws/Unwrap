//
//  PracticeSelectionAndMetadataTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Multiple-selection logic")
struct MultipleSelectionLogicTests {
    enum Scenario: CaseIterable {
        case exact
        case missingCorrectAnswer
        case selectedWrongAnswer
        case noneSelected
        case allSelected

        var expectedResult: PracticeAnswerResult {
            switch self {
            case .exact:
                .correct
            case .missingCorrectAnswer, .selectedWrongAnswer, .noneSelected, .allSelected:
                .incorrect
            }
        }
    }

    @Test("Generated Type Checker questions contain ten answers with four through six correct choices")
    func generatedAnswerCounts() {
        for seed in 0..<200 {
            let state = TypeCheckerQuestionState(random: SeededRandomSource(seed: UInt64(seed)))
            let correctCount = state.choices.count(where: \.isCorrect)

            #expect(state.choices.count == 10)
            #expect((4...6).contains(correctCount))
            #expect(Set(state.choices.map(\.id)).count == 10)
            #expect(state.prompt.contains("`"))
        }
    }

    @Test("Type Checker requires the exact selected answer set")
    func typeCheckerExactSelection() {
        for scenario in Scenario.allCases {
            var state = TypeCheckerQuestionState(prompt: "Select each String.", choices: makeTypeChoices())
            apply(scenario, to: &state)

            let result = state.submit()
            #expect(result == scenario.expectedResult, "Unexpected result for \(scenario).")
            #expect(state.isLocked)
            let repeatedResult = state.submit()
            #expect(repeatedResult == nil)
        }
    }

    @Test("Multiple-selection Review requires the exact selected answer set")
    func reviewExactSelection() {
        for scenario in Scenario.allCases {
            var state = ReviewQuestionState(
                prompt: "Select every correct answer.",
                hint: "There are two.",
                usesSyntaxHighlighting: false,
                style: .multiple,
                choices: makeReviewChoices()
            )
            apply(scenario, to: &state)

            let result = state.submit()
            #expect(result == scenario.expectedResult, "Unexpected result for \(scenario).")
            #expect(state.isLocked)
            let repeatedResult = state.submit()
            #expect(repeatedResult == nil)
        }
    }

    @Test("Result styling distinguishes correct, missed, incorrect, and untouched choices")
    func resultSemantics() {
        let choices = makeReviewChoices()
        var state = ReviewQuestionState(
            prompt: "Select every correct answer.",
            hint: "",
            usesSyntaxHighlighting: false,
            style: .multiple,
            choices: choices
        )
        state.toggleChoice(id: choices[0].id)
        state.toggleChoice(id: choices[1].id)

        #expect(state.result(for: choices[0]) == .unanswered)
        #expect(state.accessibilityValue(for: choices[0]) == "Selected")
        #expect(state.accessibilityValue(for: choices[2]) == "Not selected")
        let result = state.submit()
        #expect(result == .incorrect)
        #expect(state.result(for: choices[0]) == .correct)
        #expect(state.result(for: choices[1]) == .incorrect)
        #expect(state.result(for: choices[2]) == .missed)
        #expect(state.result(for: choices[3]) == .unanswered)
        #expect(state.accessibilityValue(for: choices[0]) == "Selected, correct")
        #expect(state.accessibilityValue(for: choices[1]) == "Selected, incorrect")
        #expect(state.accessibilityValue(for: choices[2]) == "Not selected, missed correct answer")
        #expect(state.accessibilityValue(for: choices[3]) == "Not selected")

        let selectedIDs = state.selectedChoiceIDs
        state.toggleChoice(id: choices[2].id)
        state.toggleChoice(id: 999)
        #expect(state.selectedChoiceIDs == selectedIDs)
    }

    @Test("Type Checker result styling reports missed and incorrect selections")
    func typeCheckerResultSemantics() {
        let choices = makeTypeChoices()
        var state = TypeCheckerQuestionState(prompt: "Select each String.", choices: choices)
        state.toggleChoice(id: choices[0].id)
        state.toggleChoice(id: choices[1].id)

        let result = state.submit()
        #expect(result == .incorrect)
        #expect(state.result(for: choices[0]) == .correct)
        #expect(state.result(for: choices[1]) == .incorrect)
        #expect(state.result(for: choices[2]) == .missed)
        #expect(state.result(for: choices[3]) == .unanswered)
        #expect(state.accessibilityValue(for: choices[0]) == "Selected, correct")
        #expect(state.accessibilityValue(for: choices[1]) == "Selected, incorrect")
        #expect(state.accessibilityValue(for: choices[2]) == "Not selected, missed correct answer")
        #expect(state.accessibilityValue(for: choices[3]) == "Not selected")

        let selectedIDs = state.selectedChoiceIDs
        state.toggleChoice(id: choices[2].id)
        state.toggleChoice(id: 999)
        #expect(state.selectedChoiceIDs == selectedIDs)
    }

    private func apply(_ scenario: Scenario, to state: inout TypeCheckerQuestionState) {
        let choices = state.choices

        switch scenario {
        case .exact:
            for choice in choices where choice.isCorrect {
                state.toggleChoice(id: choice.id)
            }
        case .missingCorrectAnswer:
            if let choice = choices.first(where: \.isCorrect) {
                state.toggleChoice(id: choice.id)
            }
        case .selectedWrongAnswer:
            for choice in choices where choice.isCorrect {
                state.toggleChoice(id: choice.id)
            }
            if let choice = choices.first(where: { $0.isCorrect == false }) {
                state.toggleChoice(id: choice.id)
            }
        case .noneSelected:
            break
        case .allSelected:
            for choice in choices {
                state.toggleChoice(id: choice.id)
            }
        }
    }

    private func apply(_ scenario: Scenario, to state: inout ReviewQuestionState) {
        let choices = state.choices

        switch scenario {
        case .exact:
            for choice in choices where choice.isCorrect {
                state.toggleChoice(id: choice.id)
            }
        case .missingCorrectAnswer:
            if let choice = choices.first(where: \.isCorrect) {
                state.toggleChoice(id: choice.id)
            }
        case .selectedWrongAnswer:
            for choice in choices where choice.isCorrect {
                state.toggleChoice(id: choice.id)
            }
            if let choice = choices.first(where: { $0.isCorrect == false }) {
                state.toggleChoice(id: choice.id)
            }
        case .noneSelected:
            break
        case .allSelected:
            for choice in choices {
                state.toggleChoice(id: choice.id)
            }
        }
    }

    private func makeTypeChoices() -> [TypeCheckerQuestionState.Choice] {
        [
            TypeCheckerQuestionState.Choice(id: 0, code: "let name = \"Swift\"", isCorrect: true),
            TypeCheckerQuestionState.Choice(id: 1, code: "let count = 3", isCorrect: false),
            TypeCheckerQuestionState.Choice(id: 2, code: "var city: String", isCorrect: true),
            TypeCheckerQuestionState.Choice(id: 3, code: "let enabled = true", isCorrect: false)
        ]
    }

    private func makeReviewChoices() -> [ReviewQuestionState.Choice] {
        [
            ReviewQuestionState.Choice(id: 0, text: "Correct one", reason: "", isCorrect: true),
            ReviewQuestionState.Choice(id: 1, text: "Wrong one", reason: "", isCorrect: false),
            ReviewQuestionState.Choice(id: 2, text: "Correct two", reason: "", isCorrect: true),
            ReviewQuestionState.Choice(id: 3, text: "Wrong two", reason: "", isCorrect: false)
        ]
    }
}

@Suite("Single-selection Review")
struct SingleSelectionReviewLogicTests {
    @Test("True and False choices follow the statement's truth value")
    func choiceTruthTable() {
        let expectations = [
            (statementIsTrue: true, selectedTruth: true, expected: PracticeAnswerResult.correct),
            (statementIsTrue: true, selectedTruth: false, expected: PracticeAnswerResult.incorrect),
            (statementIsTrue: false, selectedTruth: true, expected: PracticeAnswerResult.incorrect),
            (statementIsTrue: false, selectedTruth: false, expected: PracticeAnswerResult.correct)
        ]

        for expectation in expectations {
            var state = makeState(statementIsTrue: expectation.statementIsTrue)
            let earlyResult = state.submit()
            #expect(earlyResult == nil)
            state.selectTruth(expectation.selectedTruth)
            let result = state.submit()
            #expect(result == expectation.expected)
            #expect(state.isLocked)

            state.selectTruth(expectation.selectedTruth == false)
            #expect(state.selectedTruth == expectation.selectedTruth)
            let repeatedResult = state.submit()
            #expect(repeatedResult == nil)
        }
    }

    @Test("Single and multiple selection APIs cannot mutate the wrong style")
    func styleSpecificSelection() {
        var single = makeState(statementIsTrue: true)
        single.toggleChoice(id: 0)
        #expect(single.selectedChoiceIDs.isEmpty)

        var multiple = ReviewQuestionState(
            prompt: "Select it.",
            hint: "",
            usesSyntaxHighlighting: false,
            style: .multiple,
            choices: [ReviewQuestionState.Choice(id: 0, text: "A", reason: "", isCorrect: true)]
        )
        multiple.selectTruth(true)
        #expect(multiple.selectedTruth == nil)
    }

    private func makeState(statementIsTrue: Bool) -> ReviewQuestionState {
        ReviewQuestionState(
            prompt: "A statement.",
            hint: "",
            usesSyntaxHighlighting: false,
            style: .single,
            choices: [
                ReviewQuestionState.Choice(
                    id: 0,
                    text: "A statement.",
                    reason: "Because.",
                    isCorrect: statementIsTrue
                )
            ]
        )
    }
}

@Suite("Spot the Error selection")
struct SpotErrorSelectionTests {
    @Test("Selection toggles until submission, then the error line is revealed and locked")
    func selectionAndLocking() {
        let lines = [
            SpotErrorQuestionState.Line(id: 0, text: "let value = 42"),
            SpotErrorQuestionState.Line(id: 1, text: "print(value"),
            SpotErrorQuestionState.Line(id: 2, text: "print(\"Done\")")
        ]
        var state = SpotErrorQuestionState(lines: lines, error: .missingParenthesis, errorLineID: 1)

        #expect(state.isReadyToSubmit == false)
        let earlyResult = state.submit()
        #expect(earlyResult == nil)
        state.select(lineID: 0)
        #expect(state.selectedLineID == 0)
        #expect(state.result(for: lines[0]) == .selected)
        state.select(lineID: 0)
        #expect(state.selectedLineID == nil)
        state.select(lineID: 999)
        #expect(state.selectedLineID == nil)

        state.select(lineID: 0)
        let result = state.submit()
        #expect(result == .incorrect)
        #expect(state.scrollTargetID == 1)
        #expect(state.result(for: lines[0]) == .incorrect)
        #expect(state.result(for: lines[1]) == .incorrect)
        #expect(state.result(for: lines[2]) == .unanswered)

        state.select(lineID: 1)
        #expect(state.selectedLineID == 0)
        let repeatedResult = state.submit()
        #expect(repeatedResult == nil)
    }

    @Test("Selecting the generated error line is correct")
    func correctSelection() {
        let line = SpotErrorQuestionState.Line(id: 7, text: "retrun value")
        var state = SpotErrorQuestionState(lines: [line], error: .typoReturn, errorLineID: 7)
        state.select(lineID: 7)

        let result = state.submit()
        #expect(result == .correct)
        #expect(state.result(for: line) == .correct)
    }
}

@Suite("Practice metadata", .serialized)
struct PracticeMetadataTests {
    @Test("Unlock requirements match shipped learning content")
    func unlockRequirements() throws {
        let shippedSections = Set(Unwrap.chapters.flatMap(\.sections).map(\.bundleName))

        for kind in PracticeKind.allCases {
            #expect(shippedSections.contains(kind.unlockSectionID))
        }
    }

    @Test("Practice badge identifiers match the six badge-earning activities")
    func badgeIdentifiers() throws {
        let badges = try Bundle.main.decode([Badge].self, from: "Badges.json")
        let practiceBadges = badges.filter { $0.criterion == "practice" }
        let badgeIdentifiers = Set(practiceBadges.map(\.value))
        let activityIdentifiers = Set(
            PracticeKind.allCases
                .filter { $0 != .review }
                .map(\.id)
        )

        #expect(badgeIdentifiers == activityIdentifiers)
        #expect(practiceBadges.count == 6)
    }
}
