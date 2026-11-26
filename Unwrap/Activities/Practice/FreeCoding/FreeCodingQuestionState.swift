//
//  FreeCodingQuestionState.swift
//  Unwrap
//

import SwiftUI

struct FreeCodingQuestionState: Equatable {
    enum Phase: Equatable {
        case editing
        case locked
    }

    let prompt: String
    let hint: String
    let startingCode: String
    let acceptedAnswers: [String]

    private(set) var editor: FreeCodingEditorState
    private(set) var phase = Phase.editing
    private(set) var outcome: PracticeAnswerResult?

    var isLocked: Bool {
        phase == .locked
    }

    init(content: FreeCodingContent, colorScheme: ColorScheme = .light) {
        prompt = content.question
        hint = content.hint
        startingCode = content.startingCode
        acceptedAnswers = content.answers

        let initialSource = content.startingCode.isEmpty ? "" : "\(content.startingCode)\n"
        editor = FreeCodingEditorState(source: initialSource, colorScheme: colorScheme)
    }

    init(
        prompt: String,
        hint: String,
        startingCode: String,
        acceptedAnswers: [String],
        colorScheme: ColorScheme = .light
    ) {
        self.prompt = prompt
        self.hint = hint
        self.startingCode = startingCode
        self.acceptedAnswers = acceptedAnswers

        let initialSource = startingCode.isEmpty ? "" : "\(startingCode)\n"
        editor = FreeCodingEditorState(source: initialSource, colorScheme: colorScheme)
    }

    mutating func updateEditor(_ editor: FreeCodingEditorState) {
        guard isLocked == false else { return }
        self.editor = editor
    }

    mutating func rehighlight(colorScheme: ColorScheme) {
        editor.rehighlight(colorScheme: colorScheme)
    }

    mutating func insert(_ symbol: Character, colorScheme: ColorScheme) {
        guard isLocked == false else { return }
        editor.insert(symbol, colorScheme: colorScheme)
    }

    @discardableResult
    mutating func check(
        allowsRetry: Bool = true,
        using evaluator: FreeCodingEvaluator = FreeCodingEvaluator()
    ) -> PracticeAnswerResult? {
        guard isLocked == false else { return nil }

        let evaluation = evaluator.evaluate(
            answer: editor.source,
            startingCode: startingCode,
            acceptedAnswers: acceptedAnswers
        )
        if evaluation.isCorrect {
            phase = .locked
            outcome = .correct
            return .correct
        }

        if allowsRetry {
            // Practice keeps the editor active and asks the learner to try again.
            return .retryableIncorrect
        } else {
            // Challenges never allowed retries: show the wrong state, then let
            // the next tap advance with no points.
            phase = .locked
            outcome = .incorrect
            return .incorrect
        }
    }
}
