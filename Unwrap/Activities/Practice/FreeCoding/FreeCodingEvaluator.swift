//
//  FreeCodingEvaluator.swift
//  Unwrap
//

import Foundation

struct FreeCodingEvaluator {
    struct Evaluation: Equatable {
        let isCorrect: Bool
        let matches: [String]
    }

    func evaluate(answer: String, startingCode: String, acceptedAnswers: [String]) -> Evaluation {
        let cleanedAnswer = answer.replacing(startingCode, with: "")
        let anonymizedAnswer = cleanedAnswer
            .toAnonymizedVariables()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard anonymizedAnswer.isEmpty == false else {
            return Evaluation(isCorrect: false, matches: [])
        }

        let range = NSRange(anonymizedAnswer.startIndex..., in: anonymizedAnswer)

        for acceptedAnswer in acceptedAnswers {
            let anonymizedAcceptedAnswer = acceptedAnswer.toAnonymizedVariables()
            guard let expression = try? expression(from: anonymizedAcceptedAnswer),
                  let match = expression.firstMatch(in: anonymizedAnswer, range: range) else {
                continue
            }

            let matches = (1..<match.numberOfRanges).compactMap { index -> String? in
                guard let range = Range(match.range(at: index), in: anonymizedAnswer) else { return nil }
                return String(anonymizedAnswer[range])
            }

            return Evaluation(isCorrect: true, matches: matches)
        }

        return Evaluation(isCorrect: false, matches: [])
    }

    func expression(from input: String) throws -> NSRegularExpression {
        guard input.isEmpty == false else {
            throw PracticeContentError.invalidContent("Free Coding answer")
        }

        var expression = input
        let escapedCharacters = ["(", ")", "[", "]", "{", "}", "+", "-", "*", ">", "^", "$", "."]

        for character in escapedCharacters {
            expression = expression.replacing(character, with: "\\\(character)")
        }

        expression = expression.replacingOccurrences(
            of: #"(letvar|let|var) (&[1-9]+&)(:[\[\]A-Za-z0-9\\]+)"#,
            with: "$1 $2(?:$3)?",
            options: .regularExpression
        )
        expression = expression.replacing("\\(", with: "\\s*\\(")
        expression = expression.replacing("\\)", with: "\\)\\s*")
        expression = expression.replacing(",", with: "\\s*,\\s*")
        expression = expression.replacing(":", with: "\\s*:\\s*")
        expression = expression.replacing("\\{", with: "\\s*\\{\\s*")
        expression = expression.replacing("\\}", with: "\\s*\\}\\s*")
        expression = expression.replacing("letvar", with: "(?:let|var)")

        for counter in 0...10 {
            expression = expression.replacing("\(counter)_STRING", with: "([^\"]+)")
            expression = expression.replacing("\(counter)_NUMBER", with: "([0-9][0-9_]*\\.?[0-9]?)")
        }

        expression = expression.replacing("?\\s*:\\s*", with: "?:")
        expression = expression.replacing(" ", with: " *")
        return try NSRegularExpression(pattern: expression, options: .caseInsensitive)
    }
}
