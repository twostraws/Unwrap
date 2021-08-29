//
//  TypeCheckerPractice.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The Type Checker practice activity. Shows users various constants and variables and asks them to select all the lines that create a specific type.
///
/// NOTE: This doesn't have a separate TypeCheckerQuestion because there's nothing to load from JSON.
struct TypeCheckerPractice: PracticeActivity {
    /// The user-facing question the user needs to answer. This varies depending on what type we want users to find.
    var question: String

    /// An array of all the possible types.
    var answers = [Answer]()

    static let name = NSLocalizedString("Type Checker", comment: "")
    static let subtitle = NSLocalizedString("Identify data types more easily", comment: "")
    static let lockedUntil = "Type annotations"
    static let icon = UIImage(bundleName: "Practice-TypeChecker")

    init() {
        // The array of all types we want users to look at.
        var types: [(type: String, function: () -> String)] = [
            ("String", String.makeInstance),
            ("Int", Int.makeInstance),
            ("Bool", Bool.makeInstance),
            ("Double", Double.makeInstance),
            ("Float", Float.makeInstance)
        ]

        types.shuffle()
        let correctType = types[0].type

        // Format the question correctly depending on whether the type starts with a vowel.
        if types[0].type.startsWithVowel {
            question = .localizedStringWithFormat(NSLocalizedString("Which of these produces an <code>%s</code>?", comment: ""), types[0].type)
        } else {
            question = .localizedStringWithFormat(NSLocalizedString("Which of these produces a <code>%s</code>?", comment: ""), types[0].type)
        }

        let correctAnswers = Int.random(in: 4...6)

        // Add some correct answers…
        for _ in 0 ..< correctAnswers {
            answers.append(Answer(text: types[0].function(), subtitle: "", isCorrect: true, isSelected: false))
        }

        // …and some wrong answers – however many we need to bring us up to eight answers.
        while answers.count < 10 {
            let randomType = types.randomElement()!

            if randomType.type != correctType {
                answers.append(Answer(text: randomType.function(), subtitle: NSLocalizedString("This doesn't have the type you're looking for.", comment: ""), isCorrect: false, isSelected: false))
            }
        }

        answers.shuffle()
    }

    /// Creates a view controller configured with a Type Checker practice.
    static func instantiate() -> UIViewController & PracticingViewController {
        let viewController = TypeCheckerViewController.instantiate()
        viewController.review = TypeCheckerPractice()
        return viewController
    }
}
