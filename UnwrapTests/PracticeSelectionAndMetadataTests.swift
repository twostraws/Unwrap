//
//  PracticeSelectionAndMetadataTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

@Suite("Multiple-selection logic")
struct MultipleSelectionLogicTests {
    nonisolated enum Scenario: CaseIterable {
        case exact
        case missingCorrectAnswer
        case selectedWrongAnswer
        case noneSelected
        case allSelected

        var expectedResult: Bool {
            self == .exact
        }
    }

    @Test("Generated questions contain ten answers and four through six correct choices")
    func generatedAnswerCounts() {
        for _ in 0 ..< 100 {
            let practice = TypeCheckerPractice()
            let correctCount = practice.answers.count(where: \.isCorrect)

            #expect(practice.answers.count == 10)
            #expect((4 ... 6).contains(correctCount))
        }
    }

    @Test("Type Checker requires the exact selected answer set", arguments: Scenario.allCases)
    func typeCheckerExactSelection(scenario: Scenario) {
        var practice = TypeCheckerPractice()
        practice.answers = makeAnswers()

        let dataSource = TypeCheckerDataSource(review: practice)
        apply(scenario, to: &dataSource.review.answers)

        #expect(!dataSource.isUserCorrect)

        dataSource.isShowingAnswers = true
        #expect(dataSource.isUserCorrect == scenario.expectedResult)
    }

    @Test("Multiple-selection review requires the exact selected answer set", arguments: Scenario.allCases)
    func reviewExactSelection(scenario: Scenario) {
        let review = StudyReview(
            title: "Selection test",
            postscript: "",
            reviewType: "multipleSelection",
            question: "Select every correct answer.",
            hint: "",
            correct: [
                ReasonedAnswer(answer: "Correct one", reason: ""),
                ReasonedAnswer(answer: "Correct two", reason: "")
            ],
            wrong: [
                ReasonedAnswer(answer: "Wrong one", reason: ""),
                ReasonedAnswer(answer: "Wrong two", reason: "")
            ],
            syntaxHighlighting: false
        )

        let dataSource = MultipleSelectReviewDataSource(review: review)
        apply(scenario, to: &dataSource.answers)

        #expect(!dataSource.isUserCorrect)

        dataSource.isShowingAnswers = true
        #expect(dataSource.isUserCorrect == scenario.expectedResult)
    }

    private func apply(_ scenario: Scenario, to answers: inout [Answer]) {
        for index in answers.indices {
            answers[index].isSelected = false
        }

        switch scenario {
        case .exact:
            for index in answers.indices where answers[index].isCorrect {
                answers[index].isSelected = true
            }

        case .missingCorrectAnswer:
            for index in answers.indices where answers[index].isCorrect {
                answers[index].isSelected = true
            }

            if let correctIndex = answers.firstIndex(where: \.isCorrect) {
                answers[correctIndex].isSelected = false
            }

        case .selectedWrongAnswer:
            for index in answers.indices where answers[index].isCorrect {
                answers[index].isSelected = true
            }

            if let wrongIndex = answers.firstIndex(where: { !$0.isCorrect }) {
                answers[wrongIndex].isSelected = true
            }

        case .noneSelected:
            break

        case .allSelected:
            for index in answers.indices {
                answers[index].isSelected = true
            }
        }
    }

    private func makeAnswers() -> [Answer] {
        [
            Answer(text: "Correct one", subtitle: "", isCorrect: true, isSelected: false),
            Answer(text: "Wrong one", subtitle: "", isCorrect: false, isSelected: false),
            Answer(text: "Correct two", subtitle: "", isCorrect: true, isSelected: false),
            Answer(text: "Wrong two", subtitle: "", isCorrect: false, isSelected: false)
        ]
    }
}

@Suite("Single-selection review")
struct SingleSelectReviewLogicTests {
    nonisolated struct ChoiceExpectation {
        let statementIsTrue: Bool
        let selectedTrue: Bool
        let expectedResult: Bool
    }

    private nonisolated static let choiceExpectations = [
        ChoiceExpectation(statementIsTrue: true, selectedTrue: true, expectedResult: true),
        ChoiceExpectation(statementIsTrue: true, selectedTrue: false, expectedResult: false),
        ChoiceExpectation(statementIsTrue: false, selectedTrue: true, expectedResult: false),
        ChoiceExpectation(statementIsTrue: false, selectedTrue: false, expectedResult: true)
    ]

    @Test("True and False choices report whether the user was correct", arguments: Self.choiceExpectations)
    func choiceTruthTable(expectation: ChoiceExpectation) {
        let viewController = SingleSelectReviewViewController()
        let trueButton = UIButton(type: .system)
        let falseButton = UIButton(type: .system)
        viewController.trueButton = trueButton
        viewController.falseButton = falseButton
        viewController.currentAnswer = Answer(
            text: "Statement",
            subtitle: "",
            isCorrect: expectation.statementIsTrue,
            isSelected: false
        )

        viewController.showAnswer(selected: expectation.selectedTrue ? trueButton : falseButton)

        #expect(viewController.submittedAnswerWasCorrect == expectation.expectedResult)
    }
}

@Suite("Practice metadata", .serialized)
struct PracticeMetadataTests {
    @Test("Activity names and unlock requirements match shipped learning content")
    func namesAndUnlockRequirements() {
        let activities = PracticeDataSource().activities
        let expectedNames = [
            "Free Coding",
            "Predict the Output",
            "Rearrange the Lines",
            "Review",
            "Spot the Error",
            "Tap to Code",
            "Type Checker"
        ]
        let shippedSections = Set(Unwrap.chapters.flatMap(\.sections).map(\.bundleName))

        #expect(activities.map { $0.name } == expectedNames)

        for activity in activities {
            #expect(shippedSections.contains(activity.lockedUntil.bundleName))
        }
    }

    @Test("Activities unlock after their required section is learned")
    func lockingRequirements() throws {
        let previousUser: User? = User.current
        defer { User.current = previousUser }

        for activity in PracticeDataSource().activities {
            User.current = User()

            let isInitiallyLocked = activity.isLocked
            #expect(isInitiallyLocked, "A fresh user should not have unlocked \(activity.name)")

            User.current = try userWithLearnedSection(activity.lockedUntil.bundleName)

            let isUnlocked = !activity.isLocked
            #expect(isUnlocked, "Learning \(activity.lockedUntil) should unlock \(activity.name)")
        }
    }

    @Test("Practice badge identifiers match the activity identifiers")
    func badgeIdentifiers() {
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")
        let badgeIdentifiers = Set(badges.filter { $0.criterion == "practice" }.map(\.value))
        let activityIdentifiers = Set([
            FreeCodingViewController().practiceType,
            PredictTheOutputViewController().practiceType,
            RearrangeTheLinesViewController().practiceType,
            SpotTheErrorViewController().practiceType,
            TapToCodeViewController().practiceType,
            TypeCheckerViewController().practiceType
        ])

        #expect(badgeIdentifiers == activityIdentifiers)
    }

    private func userWithLearnedSection(_ section: String) throws -> User {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encodedUser = try encoder.encode(User())
        var object = try #require(JSONSerialization.jsonObject(with: encodedUser) as? [String: Any])
        object["learnedSections"] = [section]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let modifiedUser = try JSONSerialization.data(withJSONObject: object)
        return try decoder.decode(User.self, from: modifiedUser)
    }
}
