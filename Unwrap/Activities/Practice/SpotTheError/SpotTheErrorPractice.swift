//
//  SpotTheErrorPractice.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The Spot the Error practice activity. Shows users some code that contains a single random mistake, and asks them to identify it.
struct SpotTheErrorPractice: PracticeActivity {
    /// The user-facing question the user needs to answer. This one is always fixed.
    let question = "Which line of code contains an error?"

    /// The user-facing hint giving the user a nudge. Like the question, this is always fixed.
    let hint = "If there is an error, it will only be on one line. If you see one line contradict another, the earlier line will always be correct."

    /// All user-facing the code lines used in the activity.
    var code = [String]()

    /// The type of error we generated.
    var error = CodeErrorType.anonymousParameters

    /// The line number containing the error.
    var lineNumber = 0

    static let name = "Spot the Error"
    static let subtitle = "Master Swift's type system through examples"
    static let lockedUntil = "Default parameters"
    static let icon = UIImage(bundleName: "Practice-SpotTheError")

    init() {
        let items = Bundle.main.decode([SpotTheErrorQuestion].self, from: "SpotTheError.json")
        let selectedItem = items[Unwrap.getEntropy() % items.count]

        let generatedErrors = generate(from: selectedItem)
        code = generatedErrors.code.lines
        error = generatedErrors.error
        lineNumber = generatedErrors.lineNumber
    }

    /// Load a file, generate an error, then apply all replacements before sending back the finished result.
    private func generate(from question: SpotTheErrorQuestion) -> CodeError {
        let filename = "SpotTheError-\(question.file).txt"
        let code = String(bundleName: filename).trimmingCharacters(in: .whitespacesAndNewlines)

        let errorData = makeError(in: code)
        let replacedCode = applyReplacements(to: errorData.code, using: question)

        return CodeError(code: replacedCode, error: errorData.error, lineNumber: errorData.lineNumber)
    }

    /// Picks one error randomly and applies it to our code.
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func makeError(in code: String) -> CodeError {
        let output: String
        var lineNumber: Int? = nil

        let lines = code.components(separatedBy: "\n")
        let lastLine = lines.count - 1

        let error = CodeErrorType.allCases.shuffled()[0]

        switch error {
        case .badResultType:
            // result is declared as Int
            output = code.replacingOccurrences(of: "RETURN_NAME: String", with: "RETURN_NAME: Int")

        case .badReturnType:
            // returning Int/Double/Float rather than String
            lineNumber = lines.firstIndex(of: "    return RETURN_NAME")

            switch Int.random(in: 0..<3) {
            case 0:
                output = code.replacingOccurrences(of: "-> String", with: "-> Double")
            case 1:
                output = code.replacingOccurrences(of: "-> String", with: "-> Float")
            default:
                output = code.replacingOccurrences(of: "-> String", with: "-> Int")
            }

        case .badValue:
            // function is called using double/string/array of integers
            lineNumber = lastLine

            switch Int.random(in: 0..<3) {
            case 0:
                output = code.replacingOccurrences(of: "INPUT_VALUE", with: "INPUT_VALUE.\(Int.random(in: 0..<10))")
            case 1:
                output = code.replacingOccurrences(of: "INPUT_VALUE", with: "\"INPUT_VALUE\"")
            default:
                output = code.replacingOccurrences(of: "INPUT_VALUE", with: "[INPUT_VALUE]")
            }

        case .badWhitespace:
            // one instance of += has no whitespace either side
            output = code.replacingOne(of: "( \\+= )", with: " +=")

        case .missingBrace:
            // only check for opening braces, because closing braces will result in a missing line
            output = code.replacingOne(of: "(\\{)", with: "")

        case .missingMinus:
            // > String rather than - String
            lineNumber = 0
            output = code.replacingOccurrences(of: "->", with: ">")

        case .missingParenthesis:
            if code.contains(")\n") {
                // this has a final parens; remove it
                output = code.replacingOne(of: "(\\)\\n)", with: "\n")
            } else if code.contains("))") {
                // this has a double parens; remove one
                output = code.replacingOne(of: "(\\)\\))", with: ")")
            } else if code.contains(") ") {
                // this has a parens then a space; remove it
                output = code.replacingOne(of: "(\\) )", with: " ")
            } else {
                // this has no safe parens to remove; do nothing
                output = code
            }

        case .missingQuote:
            // one string is missing a quote
            output = code.replacingOne(of: "(\")", with: "")

        case .missingReturnType:
            // deleting -> String
            lineNumber = lines.firstIndex(of: "    return RETURN_NAME")
            output = code.replacingOccurrences(of: " -> String", with: "")

        case .missingReturnValue:
            // ending function with just "return"
            output = code.replacingOccurrences(of: "return RETURN_NAME", with: "return")

        case .typoCaseCall:
            // lowercasing name of function at call site
            lineNumber = lastLine
            output = code.replacingOccurrences(of: "print(FUNCTION_NAME", with: "print(function_name")

        case .typoCaseReturn:
            // Returning "string" rather than "String"
            lineNumber = 0
            output = code.replacingOne(of: "(-> String)", with: "-> string")

        case .typoColon:
            // one colon is a semicolon
            output = code.replacingOne(of: "(:)", with: ";")

        case .typoFunction:
            // "func" written as "function"
            lineNumber = 0
            output = code.replacingOne(of: "(func )", with: "function ")

        case .typoQuotes:
            // Replace double quotes with single quotes
            output = code.replacingOne(of: "(\")", with: "'")

        case .typoReturn:
            // return -> "retrun"
            output = code.replacingOccurrences(of: "return", with: "retrun")

        case .anonymousParameters:
            // first parameter has no external name
            lineNumber = lastLine
            output = code.replacingOccurrences(of: "PARAM_NAME: Int", with: "_ PARAM_NAME: Int")

        case .removingVar:
            // all code samples have a variable on line 2, so remove "var" from its declaration
            output = code.replacingOne(of: "(var )", with: "")
        }

        // If we have a specific error line number then use it, otherwise figure it out by looking at the lines.
        let errorOnLine = lineNumber ?? output.lineDiff(from: code)

        assert(errorOnLine != -1, "No error was detected in this Spot the Error practice. Error type was supposed to be \(error).")

        return CodeError(code: output, error: error, lineNumber: errorOnLine)
    }

    /// Randomizes our incoming code to make it more variable.
    private func applyReplacements(to code: String, using question: SpotTheErrorQuestion) -> String {
        var output = code

        for replacement in question.replacements {
            let possibleValues = replacement.values.shuffled()

            if let chosenValue = possibleValues.first {
                output = output.replacingOccurrences(of: replacement.name, with: chosenValue)
                output = output.replacingOccurrences(of: replacement.name.lowercased(), with: chosenValue.lowercased())
            }
        }

        output = output.replacingOccurrences(of: "INPUT_VALUE", with: String(Int.random(in: question.inputMinimum...question.inputMaximum)))

        return output
    }

    /// Creates a view controller configured with a Spot the Error practice.
    static func instantiate() -> UIViewController & PracticingViewController {
        let viewController = SpotTheErrorViewController.instantiate()
        viewController.practiceData = SpotTheErrorPractice()
        return viewController
    }
}
