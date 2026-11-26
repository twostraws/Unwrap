//
//  PredictOutputQuestionState.swift
//  Unwrap
//

import Foundation

struct PredictOutputQuestionState: Equatable {
    let prompt = "What will be printed when this code runs?"
    let hint = "You need to follow the logic line by line, as if it were running on a real device."
    let code: String
    let correctOutput: String

    var answer = ""
    private(set) var outcome: PracticeAnswerResult?

    var isLocked: Bool {
        outcome != nil
    }

    var normalizedCorrectOutput: String {
        Self.normalize(correctOutput)
    }

    mutating func updateAnswer(_ newValue: String) {
        guard isLocked == false else { return }
        answer = newValue
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard outcome == nil else { return nil }

        let isCorrect = Self.normalize(answer).lowercased() == normalizedCorrectOutput.lowercased()
        let result: PracticeAnswerResult = isCorrect ? .correct : .incorrect
        outcome = result
        return result
    }

    static func normalize(_ input: String) -> String {
        var result = input
            .replacing("“", with: "\"")
            .replacing("”", with: "\"")
            .replacing("‘", with: "'")
            .replacing("’", with: "'")

        while result.contains("  ") {
            result = result.replacing("  ", with: " ")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
