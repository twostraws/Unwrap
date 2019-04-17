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

    /// The user-facing hint giving the user a nudge. This is always fixed.
    let hint = "Remember that 0 is an integer, but 0.0 is a double."

    /// An array of all the possible types.
    var answers = [Answer]()

    static let name = "Type Checker"
    static let subtitle = "Identify data types more easily"
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
            question = "Which of these produces an <code>\(types[0].type)</code>?"
        } else {
            question = "Which of these produces a <code>\(types[0].type)</code>?"
        }

        let correctAnswers = Int.random(in: 3...5)

        // Add some correct answers…
        for _ in 0 ..< correctAnswers {
            answers.append(Answer(text: types[0].function(), subtitle: "", isCorrect: true, isSelected: false))
        }

        // …and some wrong answers – however many we need to bring us up to eight answers.
        while answers.count < 8 {
            let randomType = types.randomElement()!

            if randomType.type != correctType {
                answers.append(Answer(text: randomType.function(), subtitle: "This doesn't have the type you're looking for.", isCorrect: false, isSelected: false))
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
