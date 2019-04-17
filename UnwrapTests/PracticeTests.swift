//
//  PracticeTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that practice activities work correctly.
class PracticeTests: XCTestCase {
    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    func testFreeCoding1() {
        let question = "Write a function that accepts two strings and returns true if they are both the same regardless of what letter case they use."
        let answers = [
            "func myFunction(input1:String,input2:String) -> Bool{\nreturn input1.lowercased() == input2.lowercased()\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nreturn input1.uppercased() == input2.uppercased()\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nletvar result:Bool = input1.lowercased() == input2.lowercased()\nreturn result\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nletvar result:Bool = input1.uppercased() == input2.uppercased()\nreturn result\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.lowercased() == input2.lowercased(){\nreturn true\n}else{\nreturn false\n}\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.uppercased() == input2.uppercased(){\nreturn true\n}else{\nreturn false\n}\n}"
        ]

        let test = FreeCodingPractice(question: question, hint: "", startingCode: "", answers: answers)

        let correctAnswers = [
            "func compare(string1 str: String, against other: String) -> Bool {\nreturn str.lowercased() == other.lowercased()\n}",
            "func compare(a: String, b: String) -> Bool {\nreturn a.lowercased() == b.lowercased()\n}",
            "func compare(a1: String, b1: String) -> Bool {\nreturn a1.lowercased() == b1.lowercased()\n}",
            "func checkSame(string1: String, string2: String) -> Bool {\nreturn string1.lowercased() == string2.lowercased()\n}",
            "\nfunc checkIdentical(stringA : String, stringB : String)  ->  Bool  {\n\n\treturn stringA.lowercased()  ==  stringB.lowercased()\n\n}\n",
            "func compare(thing1 :String,thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased(){\nreturn true\n} else {\nreturn false\n}\n}",
            "  func    compare   (_ thing1 :String, _ thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased() {\nreturn true\n}\nelse\n{\nreturn false\n}\n}"
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

            // This uses invalid parameter names.
            "func check(1: String, 2: String) -> Bool {\nreturn 1 == 2\n}",

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

    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    func testFreeCoding2() {
        let question = "Write code that loops from 1 through 100 to create an array of all even numbers."
        let answers = [
            "var even1:[Int] = [Int]()\nfor i in 1...100 {\n\tif i % 2 == 0 {\n\t\teven1.append(i)\n\t}\n}",
            "var even2:[Int] = [Int]()\nfor i in 1...100 {\n\tletvar remainder = i % 2\n\tif remainder == 0 {\n\t\teven2.append(i)\n\t}\n}",
            "var even3:[Int] = [Int]()\nfor i in 1..<101 {\n\tif i % 2 == 0 {\n\t\teven3.append(i)\n\t}\n}",
            "var even4:[Int] = [Int]()\nfor i in 1..<101 {\n\tletvar remainder = i % 2\n\tif remainder == 0 {\n\t\teven4.append(i)\n\t}\n}",
            "var even5:[Int] = [Int]()\nfor i in stride(from: 2, through: 100, by: 2) {\n\teven5.append(i)\n}",
            "letvar even6:[Int] = (1...100).filter { $0 % 2 == 0 }",
            "letvar even6:[Int] = (1...100).filter { return $0 % 2 == 0 }",
            "letvar even7:[Int] = (1...100).filter { num in num % 2 == 0 }",
            "letvar even7:[Int] = (1...100).filter { num in return num % 2 == 0 }",
            "letvar even8:[Int] = (1..<101).filter { $0 % 2 == 0 }",
            "letvar even8:[Int] = (1..<101).filter { return $0 % 2 == 0 }",
            "letvar even9:[Int] = (1..<101).filter { num in num % 2 == 0 }",
            "letvar even9:[Int] = (1..<101).filter { num in return num % 2 == 0 }"
        ]

        let test = FreeCodingPractice(question: question, hint: "", startingCode: "", answers: answers)

        let correctAnswers = [
            "let evens = (1...100).filter { someNumber in return someNumber % 2 == 0 }",
            "let evens = (1...100).filter { someNumber in someNumber % 2 == 0 }",
            "let evens = (1...100).filter { return $0 % 2 == 0 }",
            "let evens = (1...100).filter { $0 % 2 == 0 }",
            "let evens = (1...100).filter {\n$0 % 2 == 0 }",
            "let evens = (1...100).filter {\n$0 % 2 == 0\n}",
            "let evens = (1...100).filter {$0 % 2 == 0\n}",
            "let evens = (1...100).filter {\n\t$0 % 2 == 0\n}",
            "let evens = (1...100).filter {\n\n\n\n return $0 % 2 == 0\n\n\n\n\n }"
        ]

        let wrongAnswers = [
            // This doesn't count high enough
            "let evens = (1..<100).filter { someNumber in return someNumber % 2 == 0 }",

            // This misses the "in"
            "let evens = (1...100).filter { someNumber return someNumber % 2 == 0 }",

            // This uses shorthand syntax as well as named parameters
            "let evens = (1...100).filter { someNumber in return $0 % 2 == 0 }"
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
