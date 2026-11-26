//
//  PracticeLogicTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Practice conditions")
struct PracticeConditionTests {
    struct ConditionExpectation {
        let left: String
        let check: String
        let right: String
        let expectedResult: Bool
    }

    @Test("Every comparison operator handles numeric boundaries")
    func numericComparisonBoundaries() throws {
        let expectations = [
            ConditionExpectation(left: "2", check: ">", right: "1", expectedResult: true),
            ConditionExpectation(left: "1", check: ">", right: "1", expectedResult: false),
            ConditionExpectation(left: "0", check: ">", right: "1", expectedResult: false),
            ConditionExpectation(left: "2", check: ">=", right: "1", expectedResult: true),
            ConditionExpectation(left: "1", check: ">=", right: "1", expectedResult: true),
            ConditionExpectation(left: "0", check: ">=", right: "1", expectedResult: false),
            ConditionExpectation(left: "0", check: "<", right: "1", expectedResult: true),
            ConditionExpectation(left: "1", check: "<", right: "1", expectedResult: false),
            ConditionExpectation(left: "2", check: "<", right: "1", expectedResult: false),
            ConditionExpectation(left: "0", check: "<=", right: "1", expectedResult: true),
            ConditionExpectation(left: "1", check: "<=", right: "1", expectedResult: true),
            ConditionExpectation(left: "2", check: "<=", right: "1", expectedResult: false),
            ConditionExpectation(left: "1", check: "==", right: "1", expectedResult: true),
            ConditionExpectation(left: "1", check: "==", right: "2", expectedResult: false),
            ConditionExpectation(left: "1", check: "!=", right: "2", expectedResult: true),
            ConditionExpectation(left: "1", check: "!=", right: "1", expectedResult: false)
        ]

        for expectation in expectations {
            let output = try resolvedOutput(
                left: expectation.left,
                check: expectation.check,
                right: expectation.right
            )
            let expectedOutput = expectation.expectedResult ? "matched" : "fallback"
            #expect(
                output == expectedOutput,
                "\(expectation.left) \(expectation.check) \(expectation.right) resolved to \(output)."
            )
        }
    }

    @Test("Non-numeric operands use lexical string comparison")
    func stringComparison() throws {
        #expect(try resolvedOutput(left: "apple", check: "<", right: "banana") == "matched")
        #expect(try resolvedOutput(left: "zebra", check: "<", right: "banana") == "fallback")
        #expect(try resolvedOutput(left: "Swift", check: "==", right: "Swift") == "matched")
        #expect(try resolvedOutput(left: "Swift", check: "!=", right: "Swift") == "fallback")
    }

    @Test("Operator placeholders use the generated operator")
    func operatorPlaceholder() throws {
        let data = try predictionData(
            code: "let result = 2 RANDOM_OPERATOR 1",
            left: "2",
            check: "OPERATOR_0",
            right: "1"
        )

        for seed in 0..<100 {
            let state = try predictState(data: data, seed: seed)
            let shouldMatch = state.code.contains(" > ")
                || state.code.contains(" >= ")
                || state.code.contains(" != ")
            #expect(state.correctOutput == (shouldMatch ? "matched" : "fallback"))
        }
    }

    @Test("Unsupported comparison operators report invalid content")
    func unsupportedOperator() throws {
        let data = try predictionData(code: "print(1)", left: "1", check: "~=", right: "1")

        do {
            _ = try predictState(data: data, seed: 0)
            Issue.record("An unsupported comparison operator should throw.")
        } catch let error as PracticeContentError {
            #expect(error == .invalidContent("PredictTheOutput condition"))
        }
    }

    private func resolvedOutput(left: String, check: String, right: String) throws -> String {
        let data = try predictionData(code: "print(1)", left: left, check: check, right: right)
        return try predictState(data: data, seed: 0).correctOutput
    }

    private func predictState(data: Data, seed: Int) throws -> PredictOutputQuestionState {
        let factory = PracticeQuestionFactory(
            user: User(),
            random: SeededRandomSource(seed: UInt64(seed)),
            loadData: { name in
                guard name == "PredictTheOutput.json" else {
                    throw BundleResourceError.missingResource(name)
                }

                return data
            }
        )

        guard case .predictOutput(let state) = try factory.makeQuestion(for: .predictTheOutput) else {
            throw PracticeContentError.invalidContent("PredictTheOutput.json")
        }

        return state
    }

    private func predictionData(code: String, left: String, check: String, right: String) throws -> Data {
        let object: [[String: Any]] = [[
            "code": code,
            "answers": [
                [
                    "conditions": [["left": left, "check": check, "right": right]],
                    "text": "matched"
                ],
                ["text": "fallback"]
            ]
        ]]
        return try JSONSerialization.data(withJSONObject: object)
    }

}

@Suite("Free Coding", .serialized)
struct FreeCodingLogicTests {
    @Test("Every bundled canonical answer is accepted")
    func bundledCanonicalAnswers() throws {
        let questions = try Bundle.main.decode(
            [FreeCodingContent].self,
            from: "FreeCoding.json"
        )
        let evaluator = FreeCodingEvaluator()

        #expect(questions.count == 11)

        for question in questions {
            #expect(
                evaluator.evaluate(
                    answer: "",
                    startingCode: question.startingCode,
                    acceptedAnswers: question.answers
                ).isCorrect == false
            )

            if question.startingCode.isEmpty == false {
                #expect(
                    evaluator.evaluate(
                        answer: question.startingCode,
                        startingCode: question.startingCode,
                        acceptedAnswers: question.answers
                    ).isCorrect == false
                )
            }

            for acceptedAnswer in question.answers {
                let representativeAnswer = acceptedAnswer
                    .replacing("letvar", with: "var")
                    .replacing("optionalreturn", with: "")

                #expect(
                    evaluator.evaluate(
                        answer: representativeAnswer,
                        startingCode: question.startingCode,
                        acceptedAnswers: [acceptedAnswer]
                    ).isCorrect,
                    "Canonical pattern rejected representative Swift: \(representativeAnswer)"
                )

                let answerWithStartingCode = question.startingCode.isEmpty
                    ? representativeAnswer
                    : "\(question.startingCode)\n\(representativeAnswer)"
                #expect(
                    evaluator.evaluate(
                        answer: answerWithStartingCode,
                        startingCode: question.startingCode,
                        acceptedAnswers: [acceptedAnswer]
                    ).isCorrect,
                    "Starting code plus canonical Swift was rejected: \(representativeAnswer)"
                )
            }
        }
    }

    @Test("String and number placeholders return captured values")
    func capturedPlaceholders() {
        let evaluator = FreeCodingEvaluator()
        let stringResult = evaluator.evaluate(
            answer: #"print("Taylor")"#,
            startingCode: "",
            acceptedAnswers: [#"print("0_STRING")"#]
        )
        let numberResult = evaluator.evaluate(
            answer: "let score = 12_345",
            startingCode: "",
            acceptedAnswers: ["letvar score = 0_NUMBER"]
        )

        #expect(stringResult == FreeCodingEvaluator.Evaluation(isCorrect: true, matches: ["Taylor"]))
        #expect(numberResult == FreeCodingEvaluator.Evaluation(isCorrect: true, matches: ["12_345"]))
    }

    @Test("Smart punctuation in a typed answer is still accepted")
    func smartPunctuationIsNormalized() {
        let evaluator = FreeCodingEvaluator()

        // Both iOS and macOS substitute curly quotes and apostrophes as the user types, so an
        // otherwise correct answer must not be rejected just because it contains a string literal.
        let curlyQuotes = evaluator.evaluate(
            answer: "print(\u{201C}Taylor\u{201D})",
            startingCode: "",
            acceptedAnswers: [#"print("0_STRING")"#]
        )
        let curlyApostrophe = evaluator.evaluate(
            answer: "print(\"Let\u{2019}s go\")",
            startingCode: "",
            acceptedAnswers: [#"print("Let's go")"#]
        )

        #expect(curlyQuotes == FreeCodingEvaluator.Evaluation(isCorrect: true, matches: ["Taylor"]))
        #expect(curlyApostrophe.isCorrect)
    }

    @Test("An empty canonical expression is rejected")
    func emptyExpression() {
        do {
            _ = try FreeCodingEvaluator().expression(from: "")
            Issue.record("An empty accepted answer should not produce a regular expression.")
        } catch let error as PracticeContentError {
            #expect(error == .invalidContent("Free Coding answer"))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Text the learner types into Free Coding is rehighlighted without changing it")
    func editorKeepsTypedText() {
        var editor = FreeCodingEditorState(source: "let name = ", colorScheme: .light)
        #expect(editor.source == "let name = ")

        for character in "\"Taylor\"" {
            editor.insert(character, colorScheme: .light)
        }
        #expect(editor.source == "let name = \"Taylor\"")

        editor.receiveEditedText(AttributedString("let name = \"Taylor\"\nprint(name)"), colorScheme: .dark)
        #expect(editor.source == "let name = \"Taylor\"\nprint(name)")

        let highlighted = SwiftCodeHighlighter().attributedString(for: editor.source, colorScheme: .dark)
        #expect(editor.attributedText == highlighted)

        // Rehighlighting text that's already highlighted for this color scheme changes nothing.
        let settled = editor
        editor.rehighlight(colorScheme: .dark)
        #expect(editor == settled)
    }

    @Test("A wrong Practice answer remains editable until the learner gets it right")
    func questionStateTransitions() {
        var state = FreeCodingQuestionState(
            prompt: "Print Swift.",
            hint: "Use print().",
            startingCode: "let language = \"Swift\"",
            acceptedAnswers: ["print(language)"]
        )

        #expect(state.editor.source == "let language = \"Swift\"\n")
        let initialResult = state.check()
        #expect(initialResult == .retryableIncorrect)
        #expect(state.phase == .editing)
        #expect(state.outcome == nil)

        var correctEditor = FreeCodingEditorState(
            source: "let language = \"Swift\"\nprint(language)",
            colorScheme: .light
        )
        correctEditor.insert("\n", colorScheme: .light)
        state.updateEditor(correctEditor)
        let correctResult = state.check()
        #expect(correctResult == .correct)
        #expect(state.phase == .locked)
        #expect(state.outcome == .correct)
        let repeatedResult = state.check()
        #expect(repeatedResult == nil)

        let lockedSource = state.editor.source
        state.insert("!", colorScheme: .light)
        state.updateEditor(FreeCodingEditorState(source: "changed", colorScheme: .light))
        #expect(state.editor.source == lockedSource)
    }

    @Test("A wrong Challenge answer locks immediately")
    func challengeAnswerLocks() {
        var state = FreeCodingQuestionState(
            prompt: "Create a value.",
            hint: "Use var.",
            startingCode: "let seed = 1",
            acceptedAnswers: ["letvar value = seedoptionalreturn"]
        )

        let result = state.check(allowsRetry: false)
        #expect(result == .incorrect)
        #expect(state.phase == .locked)
        #expect(state.outcome == .incorrect)

        let lockedSource = state.editor.source
        state.insert("!", colorScheme: .light)
        #expect(state.editor.source == lockedSource)
    }
}

@Suite("Predict the Output")
struct PredictOutputLogicTests {
    @Test("Submitted output normalizes case, quotes, apostrophes, and repeated spaces")
    func outputNormalization() {
        let expectations = [
            (target: "Hello, Swift!", submitted: "hello, swift!", expected: true),
            (target: "She said \"Hello\".", submitted: "She said “Hello”.", expected: true),
            (target: "It's ready", submitted: "It’s ready", expected: true),
            (target: "one two", submitted: "one    two", expected: true),
            (target: "one\ntwo", submitted: " \none\ntwo\n\t", expected: true),
            (target: "one\ntwo", submitted: "one two", expected: false),
            (target: "one two", submitted: "one three", expected: false)
        ]

        for expectation in expectations {
            var state = PredictOutputQuestionState(code: "print(value)", correctOutput: expectation.target)
            state.updateAnswer(expectation.submitted)
            let result = state.submit()
            #expect(result?.isCorrect == expectation.expected)
        }
    }

    @Test(
        "Whitespace around a correct answer doesn't make it wrong",
        arguments: [
            "Counted to 4 ",
            " Counted to 4",
            "Counted to 4\n",
            "  Counted to 4  ",
            "\tCounted to 4\t",
            "\r\nCounted to 4\r\n",
            " \t\nCounted to 4\n\t "
        ]
    )
    func surroundingWhitespace(submitted: String) {
        var state = PredictOutputQuestionState(code: "print(\"Counted to \\(counter)\")", correctOutput: "Counted to 4")
        state.updateAnswer(submitted)

        #expect(state.submit() == .correct)
    }

    @Test("Punctuation and spacing inside the answer still have to match")
    func meaningfulDifferences() {
        let wrongAnswers = [
            "Counted to4", "Countedto 4", "Counted to 4.", "Counted to 5", "4", "",
            "\t Counted to 5\n", "Counted\nto 4", "Counted\tto 4", " \t\n "
        ]

        for submitted in wrongAnswers {
            var state = PredictOutputQuestionState(code: "print(value)", correctOutput: "Counted to 4")
            state.updateAnswer(submitted)

            #expect(state.submit() == .incorrect, "\"\(submitted)\" should not be accepted.")
        }
    }

    @Test("The first submission locks both the answer and outcome")
    func firstSubmissionWins() {
        var state = PredictOutputQuestionState(code: "print(42)", correctOutput: "42")
        state.updateAnswer("41")

        let initialResult = state.submit()
        #expect(initialResult == .incorrect)
        #expect(state.isLocked)
        state.updateAnswer("42")
        #expect(state.answer == "41")
        let repeatedResult = state.submit()
        #expect(repeatedResult == nil)
        #expect(state.outcome == .incorrect)
    }
}
