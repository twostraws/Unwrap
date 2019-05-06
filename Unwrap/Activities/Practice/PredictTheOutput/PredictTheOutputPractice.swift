//
//  PredictTheOutputPractice.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The Predict the Output practice activity. Shows users some code and asks them to type in what it will print when run.
struct PredictTheOutputPractice: PracticeActivity {
    /// The user-facing question the user needs to answer.
    let question = "What will be printed when this code runs?"

    /// The user-facing hint giving the user a nudge.
    let hint = "You need to follow the logic line by line, as if it were running on a real device."

    /// The user-facing code that should be shown on screen.
    var code = ""

    /// The output that will be printed when the code is run.
    var answer = ""

    var correctAnswer: String {
        return process(answer)
    }

    static let name = "Predict the Output"
    static let subtitle = "Read code then predict the output"
    static let lockedUntil = "Functions: Summary"
    static let icon = UIImage(bundleName: "Practice-PredictTheOutput")

    init() {
        let items = Bundle.main.decode([PredictTheOutputQuestion].self, from: "PredictTheOutput.json")
        let selectedItem = items[Unwrap.getEntropy() % items.count]

        (code, answer) = resolve(question: selectedItem)
    }

    /// Takes a single PredictTheOutputQuestion instance, resolving all its placeholders fully. This allows these questions to appear in a variety of different forms by re-using the same underlying structure.
    func resolve(question: PredictTheOutputQuestion) -> (code: String, answer: String) {
        var names = [String]()
        var namesNatural = [String]()
        var values = [String]()
        var operators = [String]()

        let resolvedCode: String
        let resolvedAnswer: String

        // Resolve all placeholders for all parts of our question.
        (resolvedCode, names, namesNatural, values, operators) = question.code.resolvingPlaceholders()

        // Pick the first answer that is correct given our resolved data.
        let answer = selectAnswer(for: question, values: values, operators: operators)
        (resolvedAnswer, names, namesNatural, values, operators) = answer.text.resolvingPlaceholders(names: names, namesNatural: namesNatural, values: values)

        return (resolvedCode, resolvedAnswer)
    }

    /// Given a question and the data used to fill it, this goes through all possible answers and finds the first one that is correct.
    private func selectAnswer(for question: PredictTheOutputQuestion, values: [String], operators: [String]) -> PredictTheOutputAnswer {
        for answer in question.answers {
            // If this answer has no conditions use it immediately.
            guard let conditions = answer.conditions else { return answer }

            // Still here? Go through all conditions and check they are true for our values.
            for condition in conditions {
                if condition.evaluatesTrue(values: values, operators: operators) {
                    // All conditions are true, so use this answer.
                    return answer
                }
            }
        }

        // It is a logic error if no answers match our input.
        fatalError("No answer matches code: \(code)")
    }

    /// Creates a view controller configured with a Predict the Output.
    static func instantiate() -> UIViewController & PracticingViewController {
        let viewController = PredictTheOutputViewController.instantiate()
        viewController.practiceData = PredictTheOutputPractice()
        return viewController
    }

    // Checks a user's input against the correct answer, giving just a little leeway for variance.
    func answerIsCorrect(_ str: String) -> Bool {
        let targetAnswer = correctAnswer.lowercased()
        let theirAnswer = process(str).lowercased()

        // let's be generous – don't force them to get case exactly right
        return targetAnswer.lowercased() == theirAnswer.lowercased()
    }

    /// Reduces the chance of basic differences by removing smart quotes and extra spaces, but *not* collapsing case – we do that inside answerIsCorrect() so that our correctAnswer property is formatted nicely for users.
    private func process(_ string: String) -> String {
        var result = string.replacingOccurrences(of: "“", with: "\"")
        result = result.replacingOccurrences(of: "”", with: "\"")
        result = result.replacingOccurrences(of: "‘", with: "'")
        result = result.replacingOccurrences(of: "’", with: "'")
        result = result.replacingOccurrences(of: "  ", with: " ")
        return result
    }
}
