//
//  PracticeTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that practice activities work correctly.
class PracticeTests: XCTestCase {
    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    func testFreeCoding() {
        let test = FreeCodingPractice(testMode: true)

        let correctAnswers = [
            "func compare(string1 str: String, against other: String) -> Bool {\nreturn str.lowercased() == other.lowercased()\n}",
            "func checkSame(string1: String, string2: String) -> Bool {\nreturn string1.lowercased() == string2.lowercased()\n}",
            "\nfunc checkIdentical(stringA : String, stringB : String)  ->  Bool  {\n\n\treturn stringA.lowercased()  ==  stringB.lowercased()\n\n}\n",
            "func compare(thing1 :String,thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased(){\nreturn true\n} else {\nreturn false\n}",
            "  func    compare   (_ thing1 :String, _ thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased() {\nreturn true\n}\nelse\n{\nreturn false\n}"
        ]

        let wrongAnswers = [
            // This compares the string to itself by accident.
            "func compare(string1 str: String, against other: String) -> Bool {\nreturn str.lowercased() == str.lowercased()\n}",

            // This uses the wrong parameter types.
            "func check(string1 str: Int, against other: Int) -> Bool {\nreturn str.lowercased() == other.lowercased()\n}",

            // This uses no return type.
            "func check(string1 str: String, against other: String) {\nreturn str == other\n}",

            // This doesn't force the strings to match cases.
            "func check(string1 str: String, against other: String) -> Bool {\nreturn str == other\n}",

            // This has weird parameter syntax; just broken Swift.
            "func check(wotsit string1 str: String, against other: String) -> Bool {\nreturn str == other\n}"
        ]

        // Make sure all correct answers assert true.
        for answer in correctAnswers {
            let result = test.check(answer: answer)
            XCTAssertTrue(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = test.check(answer: answer)
            XCTAssertFalse(result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }

    /// Generates a variety of Predict the Output practice questions so we give everything a thorough going over.
    func testPredictTheOutput() {
        // test a wide variety of possible examples
        for _ in 1...100 {
            let test = PredictTheOutputPractice()
            XCTAssert(test.answerIsCorrect(test.answer), "Checking the answer against itself should always be true.")
        }
    }

    /// Generates a variety of Rearrange the Lines practice questions, checking both the original answer and the original answer minus whitespace.
    func testRearrangeTheLines() {
        // test a wide variety of possible examples
        for _ in 1...100 {
            let test = RearrangeTheLinesPractice()
            XCTAssertTrue(test.answerIsCorrect(test.code), "Checking the answer against itself should always be true.")

            /// Add some dummy whitespace and check again.
            let adjustedCode = test.code.map {
                return "\t" + $0 + "\t"
            }

            XCTAssertTrue(test.answerIsCorrect(adjustedCode), "Whitespace should be ignored when rearranging the lines, so that any brace can be used anywhere.")
        }
    }

    /// Generates a variety of Spot the Error activities, ensuring each one returns something other than lineNumber being -1.
    func testSpotTheError() {
        // test a wide variety of possible examples
        for _ in 1...100 {
            let test = SpotTheErrorPractice()
            XCTAssert(test.lineNumber != -1, "No errors were found in Spot the Error. Error was supposed to be \(test.error), with code \(test.code)")
        }
    }

    /// Generates a wide variety of tap to code examples, ensuring each one generates at least two test components.
    func testTapToCode() {
        // test a wide variety of possible examples
        for _ in 1...100 {
            let test = TapToCodePractice()
            XCTAssert(test.components.count >= 2, "Tap to Code practice questions must have at least two components.")
        }
    }

    /// Generates a huge variety of examples for our Type Checkere.
    func testTypeChecker() {
        // test a wide variety of possible examples
        for _ in 1...100 {
            let test = TypeCheckerPractice()
            XCTAssert(test.answers.count == 8, "There should be precisely 8 test answers.")
        }
    }
}
