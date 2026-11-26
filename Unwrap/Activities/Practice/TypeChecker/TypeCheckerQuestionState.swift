//
//  TypeCheckerQuestionState.swift
//  Unwrap
//

import Foundation

struct TypeCheckerQuestionState: Equatable {
    struct Choice: Identifiable, Equatable {
        let id: Int
        let code: String
        let isCorrect: Bool
    }

    enum ChoiceResult: Equatable {
        case unanswered
        case correct
        case incorrect
        case missed
    }

    let prompt: String
    let hint = "Any code without an explicit type will rely on type inference instead."
    let choices: [Choice]

    private(set) var selectedChoiceIDs = Set<Int>()
    private(set) var outcome: PracticeAnswerResult?

    var isLocked: Bool {
        outcome != nil
    }

    init(random: any RandomProviding) {
        let generator = PracticeValueGenerator(random: random)
        let types = random.shuffled(PracticeValueGenerator.ValueType.allCases)
        let correctType = types.first ?? .string
        let article = correctType.rawValue.first.map { "AEIOU".contains($0) } == true ? "an" : "a"
        prompt = "Which of these produces \(article) `\(correctType.rawValue)`?"

        let correctCount = random.nextInt(in: 4...6)
        var generatedChoices = [Choice]()
        var nextID = 0

        for _ in 0..<correctCount {
            generatedChoices.append(
                Choice(id: nextID, code: generator.instance(of: correctType), isCorrect: true)
            )
            nextID += 1
        }

        let wrongTypes = types.filter { $0 != correctType }
        while generatedChoices.count < 10 {
            let type = random.element(from: wrongTypes) ?? .integer
            generatedChoices.append(
                Choice(id: nextID, code: generator.instance(of: type), isCorrect: false)
            )
            nextID += 1
        }

        choices = random.shuffled(generatedChoices)
    }

    init(prompt: String, choices: [Choice]) {
        self.prompt = prompt
        self.choices = choices
    }

    mutating func toggleChoice(id: Int) {
        guard choices.contains(where: { $0.id == id }), isLocked == false else { return }

        if selectedChoiceIDs.contains(id) {
            selectedChoiceIDs.remove(id)
        } else {
            selectedChoiceIDs.insert(id)
        }
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard outcome == nil else { return nil }
        let correctIDs = Set(choices.lazy.filter(\.isCorrect).map(\.id))
        let result: PracticeAnswerResult = selectedChoiceIDs == correctIDs ? .correct : .incorrect
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
