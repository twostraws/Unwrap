//
//  PracticeAnswerOracleTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

/// Checks generated questions against answers worked out independently from the code the learner
/// is shown. Asking a question to accept its own stored answer can't catch a wrong answer; these can.
@Suite("Generated Practice answers are actually correct", .serialized)
struct PracticeAnswerOracleTests {
    @Test("Predict the Output answers match what the generated code would print")
    func predictOutputAnswers() throws {
        // Each question is generated many times on its own, so rare values such as a score
        // sitting exactly on a grade boundary are certain to come up.
        let bankData = try Bundle.main.data(named: "PredictTheOutput.json")
        let bank = try #require(JSONSerialization.jsonObject(with: bankData) as? [Any])

        #expect(bank.isEmpty == false)

        for (questionNumber, question) in bank.enumerated() {
            let questionData = try JSONSerialization.data(withJSONObject: [question])

            for seed in 0..<300 {
                let factory = PracticeQuestionFactory(
                    user: User(),
                    random: SeededRandomSource(seed: UInt64(seed)),
                    loadData: { _ in questionData }
                )

                guard case .predictOutput(let state) = try factory.makeQuestion(for: .predictTheOutput) else {
                    Issue.record("Predict the Output factory returned the wrong question kind.")
                    return
                }

                let expected = try #require(
                    try PredictedOutput.printed(by: state.code),
                    "Teach PredictedOutput.printed(by:) about question \(questionNumber) so its answer is checked:\n\(state.code)"
                )

                #expect(
                    state.correctOutput == expected,
                    "Seed \(seed) expects \"\(state.correctOutput)\" but this code prints \"\(expected)\":\n\(state.code)"
                )
            }
        }
    }

    @Test("Type Checker marks a choice correct exactly when its code has the requested type")
    func typeCheckerAnswers() throws {
        for seed in 0..<1_000 {
            let state = TypeCheckerQuestionState(random: SeededRandomSource(seed: UInt64(seed)))
            let prompt = try #require(state.prompt.wholeMatch(of: #/Which of these produces (an?) `(\w+)`\?/#))
            let requestedType = String(prompt.2)

            #expect(prompt.1 == (requestedType == "Int" ? "an" : "a"))

            for choice in state.choices {
                let actualType = try #require(
                    Self.swiftType(of: choice.code),
                    "Seed \(seed) generated code with no recognizable type: \(choice.code)"
                )

                #expect(
                    choice.isCorrect == (actualType == requestedType),
                    "Seed \(seed) asks for \(requestedType) but mislabels \(choice.code)"
                )
            }
        }
    }

    @Test("Spot the Error puts a visible mistake on the line it marks as wrong")
    func spotErrorSymptoms() throws {
        var kindsSeen = [SpotErrorQuestionState.ErrorKind]()

        for seed in 0..<400 {
            guard case .spotError(let state) = try makeQuestion(.spotTheError, seed: seed) else {
                Issue.record("Spot the Error factory returned the wrong question kind.")
                return
            }

            let lines = state.lines.map(\.text)
            let code = lines.joined(separator: "\n")

            #expect(state.lines.map(\.id) == Array(lines.indices))
            #expect(
                code.firstMatch(of: #/[A-Z]+_(NAME|PARAM|VALUE)/#) == nil,
                "Seed \(seed) left a placeholder in the code:\n\(code)"
            )
            #expect(
                try Self.showsSymptom(of: state.error, onLine: state.errorLineID, of: lines),
                "Seed \(seed): line \(state.errorLineID) doesn't show \(state.error):\n\(code)"
            )

            if kindsSeen.contains(state.error) == false {
                kindsSeen.append(state.error)
            }
        }

        #expect(kindsSeen.count == SpotErrorQuestionState.ErrorKind.allCases.count)
    }

    private func makeQuestion(_ kind: PracticeKind, seed: Int) throws -> PracticeQuestion {
        try PracticeQuestionFactory(
            user: User(),
            random: SeededRandomSource(seed: UInt64(seed))
        ).makeQuestion(for: kind)
    }

    /// Works out a declaration's type the way a learner would: an annotation wins, otherwise the literal decides.
    private static func swiftType(of code: String) -> String? {
        if let annotation = code.firstMatch(of: #/: (String|Int|Bool|Double|Float) = /#) {
            return String(annotation.1)
        }

        guard let literal = code.firstMatch(of: #/ = (.+)$/#)?.1 else { return nil }

        if literal.hasPrefix("\""), literal.hasSuffix("\"") {
            return "String"
        } else if literal == "true" || literal == "false" {
            return "Bool"
        } else if Int(literal) != nil {
            return "Int"
        } else if Double(literal) != nil {
            return "Double"
        } else {
            return nil
        }
    }

    private static func showsSymptom(
        of error: SpotErrorQuestionState.ErrorKind,
        onLine errorIndex: Int,
        of lines: [String]
    ) throws -> Bool {
        let line = try #require(lines.indices.contains(errorIndex) ? lines[errorIndex] : nil)
        let statement = line.trimmingCharacters(in: .whitespaces)
        let signature = try #require(lines.first)
        let call = try #require(lines.last)
        let isSignature = errorIndex == 0
        let isCall = errorIndex == lines.count - 1
        let returnsValue = statement.hasPrefix("return ")

        switch error {
        case .badResultType:
            return line.contains(": Int = \"")
        case .badReturnType:
            return signature.contains(#/-> (Double|Float|Int) \{/#) && returnsValue
        case .badValue:
            return isCall && call.contains(#/: (\d+\.\d|"\d+"|\[\d+\])[,)]/#)
        case .badWhitespace:
            return line.contains(#/ \+=\S/#)
        case .missingBrace:
            let code = lines.joined(separator: "\n")
            return line.contains("{") == false && count("{", in: code) == count("}", in: code) - 1
        case .missingMinus:
            return isSignature && signature.contains("->") == false && signature.contains(") > String")
        case .missingParenthesis:
            return count("(", in: line) != count(")", in: line)
        case .missingQuote:
            return count("\"", in: line).isMultiple(of: 2) == false
        case .missingReturnType:
            return signature.contains("->") == false && returnsValue
        case .missingReturnValue:
            return statement == "return"
        case .typoCaseCall:
            let name = try #require(signature.firstMatch(of: #/func (\w+)\(/#)?.1)
            return isCall && call.contains("print(\(name)(") == false && call.contains("print(\(name.lowercased())(")
        case .typoCaseReturn:
            return isSignature && signature.contains("-> string")
        case .typoColon:
            return line.contains(";")
        case .typoFunction:
            return isSignature && signature.hasPrefix("function ")
        case .typoQuotes:
            return count("\"", in: line).isMultiple(of: 2) == false && line.contains("'")
        case .typoReturn:
            return statement.hasPrefix("retrun")
        case .anonymousParameters:
            return isCall && signature.contains("(_ ")
        case .removingVar:
            return statement.contains(#/^\w+(: String)? = /#)
        }
    }

    private static func count(_ character: Character, in text: String) -> Int {
        text.count { $0 == character }
    }
}

/// A tiny interpreter for the shapes of code in PredictTheOutput.json. It reads only the
/// generated Swift, never the question's stored answer.
private enum PredictedOutput {
    static func printed(by code: String) throws -> String? {
        let integers = code.matches(of: #/ = (\d+)(\n|$)/#).compactMap { Int($0.1) }
        let strings = code.matches(of: #/ = "([^"]*)"/#).map { String($0.1) }

        if code.contains("switch score") {
            let score = try #require(integers.first)
            return grade(for: score)
        } else if code.contains("counter += 1") {
            let limit = try #require(code.firstMatch(of: #/if i == (\d+)/#).flatMap { Int($0.1) })
            return "Counted to \(limit - 1)"
        } else if code.contains("multiplied % 2") {
            try #require(integers.count == 2)
            return (integers[0] * integers[1]).isMultiple(of: 2) ? "Even number" : "Odd number"
        } else if code.contains("The sum is") {
            try #require(integers.count == 3)
            return "The sum is \(integers.reduce(0, +))"
        } else if code.contains("default: \"Unknown\"") {
            return "Unknown"
        }

        let declaration = try #require(code.firstMatch(of: #/^(?:let|var) (\w+) = /#))
        let name = String(declaration.1)

        if code.contains("inout") {
            try #require(name.hasSuffix("Value"))
            return "\(naturalName(for: String(name.dropLast(5)))) is now 0"
        } else if code.contains("doubled is") {
            let value = try #require(integers.first)
            return "\(naturalName(for: name)) doubled is \(value * 2)"
        } else if let comparison = code.firstMatch(of: #/\.count (\S+) (\d+) \{/#) {
            try #require(strings.count == 2)
            let limit = try #require(Int(comparison.2))
            let replaced = try compare(strings[0].count, String(comparison.1), limit)
            return "\(naturalName(for: name)) is \(replaced ? strings[1] : strings[0])"
        } else if code.contains("print(\""), let finalValue = strings.last {
            return "\(naturalName(for: name)) is \(finalValue)"
        }

        return nil
    }

    private static func grade(for score: Int) -> String {
        switch score {
        case 0...50: "Fail"
        case 51...70: "Pass"
        case 71...85: "Merit"
        default: "Distinction"
        }
    }

    private static func compare(_ left: Int, _ comparison: String, _ right: Int) throws -> Bool {
        switch comparison {
        case "<": left < right
        case "<=": left <= right
        case ">": left > right
        case ">=": left >= right
        case "==": left == right
        case "!=": left != right
        default: throw PracticeContentError.invalidContent("Unknown operator \(comparison)")
        }
    }

    /// Turns a camel-cased variable name such as `numberOfUsers` into "Number of users".
    private static func naturalName(for variableName: String) -> String {
        let words = variableName.replacing(#/[A-Z]/#) { " \($0.output.lowercased())" }
        return words.prefix(1).uppercased() + words.dropFirst()
    }
}
