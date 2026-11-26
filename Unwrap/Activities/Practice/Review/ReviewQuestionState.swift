//
//  ReviewQuestionState.swift
//  Unwrap
//

import Foundation

struct ReviewQuestionState: Equatable {
    struct Choice: Identifiable, Equatable {
        let id: Int
        let text: String
        let reason: String
        let isCorrect: Bool
    }

    enum Style: Equatable {
        case single
        case multiple
    }

    enum ChoiceResult: Equatable {
        case unanswered
        case correct
        case incorrect
        case missed
    }

    let prompt: String
    let hint: String
    let usesSyntaxHighlighting: Bool
    let style: Style
    let choices: [Choice]

    private(set) var selectedChoiceIDs = Set<Int>()
    private(set) var selectedTruth: Bool?
    private(set) var outcome: PracticeAnswerResult?

    var isLocked: Bool {
        outcome != nil
    }

    mutating func selectTruth(_ value: Bool) {
        guard style == .single, isLocked == false else { return }
        selectedTruth = value
    }

    mutating func toggleChoice(id: Int) {
        guard style == .multiple,
              choices.contains(where: { $0.id == id }),
              isLocked == false else {
            return
        }

        if selectedChoiceIDs.contains(id) {
            selectedChoiceIDs.remove(id)
        } else {
            selectedChoiceIDs.insert(id)
        }
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard outcome == nil else { return nil }

        let isCorrect: Bool
        switch style {
        case .single:
            guard let choice = choices.first, let selectedTruth else { return nil }
            isCorrect = selectedTruth == choice.isCorrect
        case .multiple:
            let correctIDs = Set(choices.lazy.filter(\.isCorrect).map(\.id))
            isCorrect = selectedChoiceIDs == correctIDs
        }

        let result: PracticeAnswerResult = isCorrect ? .correct : .incorrect
        outcome = result
        return result
    }

    func result(for choice: Choice) -> ChoiceResult {
        guard outcome != nil else { return .unanswered }

        if choice.isCorrect {
            return selectedChoiceIDs.contains(choice.id) ? .correct : .missed
        }

        return selectedChoiceIDs.contains(choice.id) ? .incorrect : .unanswered
    }

    func accessibilityValue(for choice: Choice) -> String {
        switch result(for: choice) {
        case .unanswered:
            selectedChoiceIDs.contains(choice.id) ? "Selected" : "Not selected"
        case .correct:
            "Selected, correct"
        case .incorrect:
            "Selected, incorrect"
        case .missed:
            "Not selected, missed correct answer"
        }
    }
}
