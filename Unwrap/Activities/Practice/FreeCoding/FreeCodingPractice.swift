//
//  FreeCodingPractice.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The Free Coding practice activity. Shows users a question and asks them to write Swift code to solve the problem.
struct FreeCodingPractice: PracticeActivity {
    /// The user-facing question the user needs to answer.
    var question: String

    /// The user-facing hint giving the user a nudge.
    var hint: String

    /// The user-facing code that should be pre-filled in the UI to give the user the right start.
    var startingCode: String

    /// An array of possible answers that correctly answer the question.
    var answers: [String]

    static let name = "Free Coding"
    static let subtitle = "Write code to solve problems"
    static let lockedUntil = "Typecasting"
    static let icon = UIImage(bundleName: "Practice-FreeCoding")

    /// Creates a view controller configured with a Free Coding activity.
    static func instantiate() -> UIViewController & PracticingViewController {
        let viewController = FreeCodingViewController.instantiate()
        viewController.practiceData = FreeCodingPractice()
        return viewController
    }

    /// Checks a user's free-text answer is correct, while also returning any interesting matches. The matches return – although unused currently – allows us to do things like "create a variable that contains your name" then read the name they used.
    func check(answer: String) -> (isCorrect: Bool, matches: [String]) {
        // Remove any starting code; this isn't part of the answer.
        let cleanedAnswer = answer.replacingOccurrences(of: startingCode, with: "")

        // Homogenize the code they wrote.
        let answer = cleanedAnswer.toAnonymizedVariables().trimmingCharacters(in: .whitespacesAndNewlines)
        let range = NSRange(location: 0, length: answer.utf16.count)

        guard !answer.isEmpty else {
            // They didn't provide any input, so bail out immediately
            return (false, [])
        }

        // Loop over all the answers we have, attempting to find one that matches their input.
        for possibleAnswer in answers {
            // Homogenize this answer.
            let possibleAnswer = possibleAnswer.toAnonymizedVariables()

            // Convert it into a regular expression, allowing us to be flexible about how they use whitespace and similar, while also capturing interesting values.
            let expression = regex(from: possibleAnswer)

            if let match = expression.firstMatch(in: answer, options: [], range: range) {
                // We got a match – their answer was correct.
                var inputMatches = [String]()

                // Go over all the interesting matches we found and prepare to send them back.
                for index in 1 ..< match.numberOfRanges {
                    let range = match.range(at: index)

                    if let swiftRange = Range(range, in: answer) {
                        let matchString = String(answer[swiftRange])
                        inputMatches.append(matchString)
                    }
                }

                return (true, inputMatches)
            }
        }

        // No answers matched the user's input.
        return (false, [])
    }

    // Convert a code string into a regular expression, allowing us to do really flexible matching for code styles.
    func regex(from string: String) -> NSRegularExpression {
        assert(string.isEmpty == false, "You can't create a regex from an empty string.")

        var expr = string

        // First we need to escape any characters that have meaning in regexes.
        expr = expr.replacingOccurrences(of: "(", with: "\\(")
        expr = expr.replacingOccurrences(of: ")", with: "\\)")
        expr = expr.replacingOccurrences(of: "[", with: "\\[")
        expr = expr.replacingOccurrences(of: "]", with: "\\]")
        expr = expr.replacingOccurrences(of: "{", with: "\\{")
        expr = expr.replacingOccurrences(of: "}", with: "\\}")
        expr = expr.replacingOccurrences(of: "+", with: "\\+")
        expr = expr.replacingOccurrences(of: "-", with: "\\-")
        expr = expr.replacingOccurrences(of: "*", with: "\\*")
        expr = expr.replacingOccurrences(of: ">", with: "\\>")
        expr = expr.replacingOccurrences(of: "^", with: "\\^")
        expr = expr.replacingOccurrences(of: "$", with: "\\$")
        expr = expr.replacingOccurrences(of: ".", with: "\\.")

        // Now we need to transform the string so that it accepts a variety of different coding approaches.

        // Make type inference optional.
        expr = expr.replacingOccurrences(of: "(letvar|let|var) (&[1-9]+&)(:[\\[\\]A-Za-z0-9\\\\]+)", with: "$1 $2(?:$3)?", options: .regularExpression)

        // Allow whitespace before or after parentheses.
        expr = expr.replacingOccurrences(of: "\\(", with: "\\s*\\(")
        expr = expr.replacingOccurrences(of: "\\)", with: "\\)\\s*")

        // Allow whitespace before or after commas, colons, and braces.
        expr = expr.replacingOccurrences(of: ",", with: "\\s*,\\s*")
        expr = expr.replacingOccurrences(of: ":", with: "\\s*:\\s*")
        expr = expr.replacingOccurrences(of: "\\{", with: "\\s*\\{\\s*")
        expr = expr.replacingOccurrences(of: "\\}", with: "\\s*\\}\\s*")

        // Allow let or var where requested.
        expr = expr.replacingOccurrences(of: "letvar", with: "(?:let|var)")

        // Prepare to capture any user values we care about.
        for counter in 0 ... 10 {
            expr = expr.replacingOccurrences(of: "\(counter)_STRING", with: "([^\"]+)")
            expr = expr.replacingOccurrences(of: "\(counter)_NUMBER", with: "([0-9][0-9_]*\\.?[0-9]?)")
        }

        // Fix any mistakes!
        // Our example code always uses explicit types, but the above code makes them optional. However, the code above will cause problems: it will convert "a:Int" into "a:(?:Int)?", then try to allow whitespace around the colon, giving "a\\s*:\\s*(?\\s*:\\s*Int)?". What we *want* is "a\\s*:\\s*(?:Int)?" so we'll do some cleanup below to fix this.
        expr = expr.replacingOccurrences(of: "?\\s*:\\s*", with: "?:")

        // Make one space match zero or more spaces
        expr = expr.replacingOccurrences(of: " ", with: " *")

        // We're done – the whole thing is now a valid regex.

        do {
            return try NSRegularExpression(pattern: expr, options: .caseInsensitive)
        } catch {
            fatalError("Invalid regular expression \"\(expr)\"; original input string was \"\(string)\". \(error.localizedDescription)")
        }
    }
}

extension FreeCodingPractice {
    /// Loads a single FreeCodingQuestion into an activity. This is kept separate so we retain the memberwise initializer for testing purposes.
    init() {
        var items = Bundle.main.decode([FreeCodingQuestion].self, from: "FreeCoding.json")
        let selectedItem: FreeCodingQuestion
        selectedItem = items[Unwrap.getEntropy() % items.count]

        question = selectedItem.question
        hint = selectedItem.hint
        startingCode = selectedItem.startingCode
        answers = selectedItem.answers
    }
}
