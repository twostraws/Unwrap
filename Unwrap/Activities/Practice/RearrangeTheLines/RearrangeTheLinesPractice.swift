//
//  RearrangeTheLinesPractice.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The Predict the Output practice activity. Shows users some code where the lines are mixed up, and asks users to place them in the correct order.
struct RearrangeTheLinesPractice: PracticeActivity {
    /// The user-facing question the user needs to answer.
    var question: String

    /// The user-facing hint giving the user a nudge.
    var hint: String

    /// The user-facing code that should be shown on screen, line by line, in the correct order.
    var code: [String]

    static let name = "Rearrange the Lines"
    static let subtitle = "Rearrange code to make it build"
    static let lockedUntil = "Mutability"
    static let icon = UIImage(bundleName: "Practice-RearrangeTheLines")

    init() {
        let items = Bundle.main.decode([RearrangeTheLinesQuestion].self, from: "RearrangeTheLines.json")
        let selectedItem = items[Unwrap.getEntropy() % items.count]

        question = selectedItem.question
        hint = selectedItem.hint

        // replace tabs with three spaces to save whitespace, then send back that as a string array
        let spacedCode = selectedItem.code.replacingOccurrences(of: "\t", with: "   ")
        code = spacedCode.lines
    }

    /// Creates a view controller configured with a Rearrange the Lines practice.
    static func instantiate() -> UIViewController & PracticingViewController {
        let viewController = RearrangeTheLinesViewController.instantiate()
        viewController.practiceData = RearrangeTheLinesPractice()
        return viewController
    }

    // Checks a user's input against the correct answer, ignoring whitespace.
    func answerIsCorrect(_ answer: [String]) -> Bool {
        // we don't care about whitespace – they can use any brace they want, regardless of its indentation level
        let trimmedAnswer = answer.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let correctAnswer = code.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        return trimmedAnswer == correctAnswer
    }
}
