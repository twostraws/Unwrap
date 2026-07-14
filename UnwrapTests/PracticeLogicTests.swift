//
//  PracticeLogicTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

@Suite("Practice conditions")
struct PracticeConditionTests {
    nonisolated struct ConditionExpectation {
        let left: String
        let check: String
        let right: String
        let expectedResult: Bool
    }

    private nonisolated static let conditionExpectations = [
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

    @Test("Every comparison operator handles its boundaries", arguments: Self.conditionExpectations)
    func comparisonOperators(expectation: ConditionExpectation) {
        let condition = Condition(left: "VALUE_0", check: expectation.check, right: "VALUE_1")

        #expect(condition.evaluatesTrue(values: [expectation.left, expectation.right], operators: []) == expectation.expectedResult)
    }

    @Test("An operator placeholder uses the supplied operator")
    func operatorPlaceholder() {
        let condition = Condition(left: "2", check: "OPERATOR_0", right: "1")

        #expect(condition.evaluatesTrue(values: [], operators: [">"]))
        #expect(!condition.evaluatesTrue(values: [], operators: ["<"]))
    }

    @Test("Non-numeric operands are compared as strings")
    func stringComparison() {
        let condition = Condition(left: "apple", check: "<", right: "banana")

        #expect(condition.evaluatesTrue(values: [], operators: []))
    }
}

@Suite("Free Coding")
struct FreeCodingLogicTests {
    @Test("Every bundled canonical answer is accepted")
    func bundledCanonicalAnswers() {
        let questions = Bundle.main.decode([FreeCodingQuestion].self, from: "FreeCoding.json")

        #expect(questions.count == 11)

        for question in questions {
            let fullPractice = FreeCodingPractice(
                question: question.question,
                hint: question.hint,
                startingCode: question.startingCode,
                answers: question.answers
            )

            #expect(!fullPractice.check(answer: "").isCorrect)

            if !question.startingCode.isEmpty {
                #expect(!fullPractice.check(answer: question.startingCode).isCorrect)
            }

            for answer in question.answers {
                let practice = FreeCodingPractice(
                    question: question.question,
                    hint: question.hint,
                    startingCode: question.startingCode,
                    answers: [answer]
                )

                let representativeAnswer = answer
                    .replacing("letvar", with: "var")
                    .replacing("optionalreturn", with: "")

                #expect(
                    practice.check(answer: representativeAnswer).isCorrect,
                    "Canonical answer pattern should accept representative Swift: \(representativeAnswer)"
                )

                let answerWithStartingCode = "\(question.startingCode)\n\(representativeAnswer)"
                #expect(
                    practice.check(answer: answerWithStartingCode).isCorrect,
                    "Starting code plus representative Swift should be accepted: \(representativeAnswer)"
                )
            }
        }
    }

    @Test("Captured string placeholders are returned")
    func capturedStringPlaceholder() {
        let practice = FreeCodingPractice(
            question: "Print a name.",
            hint: "",
            startingCode: "",
            answers: [#"print("0_STRING")"#]
        )

        let result = practice.check(answer: #"print("Taylor")"#)

        #expect(result.isCorrect)
        #expect(result.matches == ["Taylor"])
    }
}

@Suite("Predict the Output")
struct PredictTheOutputLogicTests {
    nonisolated struct OutputNormalizationExpectation {
        let target: String
        let submitted: String
        let expectedResult: Bool
    }

    private nonisolated static let outputNormalizationExpectations = [
        OutputNormalizationExpectation(target: "Hello, Swift!", submitted: "hello, swift!", expectedResult: true),
        OutputNormalizationExpectation(target: "She said \"Hello\".", submitted: "She said “Hello”.", expectedResult: true),
        OutputNormalizationExpectation(target: "It's ready", submitted: "It’s ready", expectedResult: true),
        OutputNormalizationExpectation(target: "one two", submitted: "one    two", expectedResult: true),
        OutputNormalizationExpectation(target: "one two", submitted: "one three", expectedResult: false)
    ]

    @Test("Submitted output is normalized", arguments: Self.outputNormalizationExpectations)
    func outputNormalization(expectation: OutputNormalizationExpectation) {
        var practice = PredictTheOutputPractice()
        practice.answer = expectation.target

        #expect(practice.answerIsCorrect(expectation.submitted) == expectation.expectedResult)
    }

    @Test("Every condition must match before an answer is selected")
    func allConditionsMustMatch() {
        let question = PredictTheOutputQuestion(
            code: "let value = RANDOM_SMALL_INT",
            answers: [
                PredictTheOutputAnswer(
                    conditions: [
                        Condition(left: "VALUE_0", check: ">", right: "0"),
                        Condition(left: "VALUE_0", check: "<", right: "0")
                    ],
                    text: "Incorrect conditional answer"
                ),
                PredictTheOutputAnswer(conditions: nil, text: "Fallback answer")
            ]
        )

        let resolved = PredictTheOutputPractice().resolve(question: question)

        #expect(resolved.answer == "Fallback answer")
    }

    @Test("An answer is selected when all its conditions match")
    func allConditionsMatch() {
        let question = PredictTheOutputQuestion(
            code: "let value = RANDOM_SMALL_INT",
            answers: [
                PredictTheOutputAnswer(
                    conditions: [
                        Condition(left: "VALUE_0", check: ">", right: "0"),
                        Condition(left: "VALUE_0", check: "<=", right: "10")
                    ],
                    text: "Conditional answer"
                ),
                PredictTheOutputAnswer(conditions: nil, text: "Fallback answer")
            ]
        )

        let resolved = PredictTheOutputPractice().resolve(question: question)

        #expect(resolved.answer == "Conditional answer")
    }

    @Test("A nil-condition answer acts as the fallback")
    func fallbackAnswer() {
        let question = PredictTheOutputQuestion(
            code: "let value = RANDOM_SMALL_INT",
            answers: [
                PredictTheOutputAnswer(
                    conditions: [Condition(left: "VALUE_0", check: "<", right: "0")],
                    text: "Conditional answer"
                ),
                PredictTheOutputAnswer(conditions: nil, text: "Fallback answer")
            ]
        )

        let resolved = PredictTheOutputPractice().resolve(question: question)

        #expect(resolved.answer == "Fallback answer")
    }

    @Test("Every bundled question resolves completely and accepts its answer")
    func bundledQuestionsResolve() {
        let questions = Bundle.main.decode([PredictTheOutputQuestion].self, from: "PredictTheOutput.json")
        var practice = PredictTheOutputPractice()

        for question in questions {
            for _ in 0 ..< 20 {
                let resolved = practice.resolve(question: question)

                #expect(!containsUnresolvedPlaceholder(in: resolved.code))
                #expect(!containsUnresolvedPlaceholder(in: resolved.answer))

                practice.answer = resolved.answer
                #expect(practice.answerIsCorrect(resolved.answer))
            }
        }
    }

    private func containsUnresolvedPlaceholder(in string: String) -> Bool {
        let pattern = #"RANDOM_|CONSTANT_OR_VARIABLE|TRUE_OR_FALSE|NAME_(?:NATURAL_)?[0-9]|VALUE_[0-9]|OPERATOR_[0-9]|\$\{"#
        return string.range(of: pattern, options: .regularExpression) != nil
    }
}

@Suite("Rearrange the Lines")
struct RearrangeTheLinesLogicTests {
    @Test("Correctness requires the same lines in the same order")
    func answerCorrectness() {
        let practice = makePractice()

        #expect(practice.answerIsCorrect(["let value = 42", "print(value)"]))
        #expect(practice.answerIsCorrect(["  let value = 42\t", "\tprint(value)  "]))
        #expect(!practice.answerIsCorrect(["print(value)", "let value = 42"]))
        #expect(!practice.answerIsCorrect(["let value = 42"]))
        #expect(!practice.answerIsCorrect(["let value = 42", "print(value)", "print(value)"]))
    }

    @Test("The data source handles missing and additional lines safely")
    func dataSourceCardinality() {
        let practice = makePractice()
        let dataSource = RearrangeTheLinesDataSource(practiceData: practice)

        dataSource.currentCode = practice.code
        #expect(dataSource.isUserCorrect)

        dataSource.currentCode = [practice.code[0]]
        #expect(!dataSource.isUserCorrect)

        dataSource.currentCode = practice.code + ["print(value)"]
        #expect(!dataSource.isUserCorrect)
    }

    private func makePractice() -> RearrangeTheLinesPractice {
        var practice = RearrangeTheLinesPractice()
        practice.question = "Put the lines in order."
        practice.hint = "Create the value before using it."
        practice.code = ["let value = 42", "print(value)"]
        return practice
    }
}

@Suite("Tap to Code")
struct TapToCodeModelTests {
    @Test("Moving words preserves counts and the complete multiset")
    func movingWordsPreservesContent() {
        var model = makeModel()
        let expectedWords = model.correctWords.sorted()
        let movedWord = model.allWords[0]

        model.moveToUsed(IndexPath(item: 0, section: 0), to: IndexPath(item: 0, section: 0))

        #expect(model.usedWords == [movedWord])
        #expect(model.allWords.count == 2)
        #expect((model.usedWords + model.allWords).sorted() == expectedWords)

        model.moveToAll(IndexPath(item: 0, section: 0), to: IndexPath(item: model.allWords.count, section: 0))

        #expect(model.usedWords.isEmpty)
        #expect(model.allWords.count == 3)
        #expect(model.allWords.sorted() == expectedWords)
    }

    @Test("Counts are routed to the matching collection")
    func collectionCounts() {
        var model = makeModel()
        let allWords = AllWordsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let usedWords = UsedWordsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        #expect(model.count(for: allWords) == 3)
        #expect(model.count(for: usedWords) == 0)

        model.moveToUsed(IndexPath(item: 0, section: 0), to: IndexPath(item: 0, section: 0))

        #expect(model.count(for: allWords) == 2)
        #expect(model.count(for: usedWords) == 1)
    }

    @Test("Only the complete correct order is accepted")
    func correctnessAndRearranging() throws {
        var model = makeModel()

        #expect(!model.isUserCorrect)

        for correctWord in model.correctWords {
            let source = try #require(model.allWords.firstIndex(of: correctWord))
            let destination = model.usedWords.count
            model.moveToUsed(IndexPath(item: source, section: 0), to: IndexPath(item: destination, section: 0))
        }

        #expect(model.allWords.isEmpty)
        #expect(model.isUserCorrect)

        model.rearrange(IndexPath(item: 0, section: 0), to: IndexPath(item: 2, section: 0))
        #expect(!model.isUserCorrect)

        model.rearrange(IndexPath(item: 2, section: 0), to: IndexPath(item: 0, section: 0))
        #expect(model.isUserCorrect)
    }

    private func makeModel() -> TapToCodeModel {
        let practice = TapToCodePractice()
        practice.question = "Build the code."
        practice.existingCode = ""
        practice.components = ["alpha", "beta", "gamma"]

        return TapToCodeModel(practiceData: practice, names: [], namesNatural: [], values: [], operators: [])
    }
}
