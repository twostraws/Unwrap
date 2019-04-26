//
//  ExtensionTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that our various small extensions work as planned.
class ExtensionTests: XCTestCase {
    /// Tests our code to check whether two dates are the same day.
    func testSameDay() {
        let today = Date()
        let alsoToday = today
        let notToday = today.addingTimeInterval(100000)

        XCTAssertTrue(today.isSameDay(as: alsoToday))
        XCTAssertFalse(today.isSameDay(as: notToday))
    }

    /// Tests our code to count the number of days between two dates.
    func testDaysBetween() {
        let today = Date()

        var dayComponent = DateComponents()
        let calendar = NSCalendar.current

        for dayCount in 1...10 {
            dayComponent.day = dayCount

            guard let futureDate = calendar.date(byAdding: dayComponent, to: today) else {
                XCTFail("Somehow managed to create a bad date.")
                return
            }

            XCTAssert(today.days(between: futureDate) == dayCount, "Calculating the gap between days was not correct.")
        }
    }

    /// Tests the startsWithVowel property correctly identifies strings that start with vowels.
    func testVowels() {
        XCTAssertTrue("Andrew".startsWithVowel)
        XCTAssertTrue("Olivia".startsWithVowel)
        XCTAssertTrue("ETHAN".startsWithVowel)
        XCTAssertTrue("URSULA".startsWithVowel)
        XCTAssertFalse("Chris".startsWithVowel)
        XCTAssertFalse("CHARLOTTE".startsWithVowel)
        XCTAssertFalse("Mark".startsWithVowel)
        XCTAssertFalse("SOPHIE".startsWithVowel)
    }

    /// Tests that splitting a string into lines works correctly.
    func testStringLines() {
        let test1 = "Hello"
        let test2 = "Hello\nworld"
        let test5 = "Hello\ndarkness\nmy\nold\nfriend"

        XCTAssertEqual(test1.lines.count, 1, "There should be 1 line in \(test1).")
        XCTAssertEqual(test2.lines.count, 2, "There should be 2 lines in \(test2).")
        XCTAssertEqual(test5.lines.count, 5, "There should be 5 lines in \(test5).")
    }

    /// Tests that line differences are detected correctly.
    func testLineDiff() {
        let testA = "This\nis\na\ntest"
        let testB = "This\nis\na\nmess"

        XCTAssertEqual(testA.lineDiff(from: testB), 3, "Line 3 is different.")
        XCTAssertEqual(testA.lineDiff(from: testA), -1, "There are no differences.")
    }

    /// Tests that strings can be formatted into variable names correctly.
    func testVariableFormatting() {
        let tests = [
            "Number of cars": "numberOfCars",
            "MY NAME IS INIGO MONTOYA": "myNameIsInigoMontoya",
            "You Fight Like A Dairy Farmer": "youFightLikeADairyFarmer"
        ]

        for test in tests {
            XCTAssert(test.key.formatAsVariable() == test.value, "Converting \"\(test.key)\" to a variable should produce \"\(test.value)\", but \(test.key.formatAsVariable()) was returned instead.")
        }
    }

    /// Tests that code can be anonymized and homogenized.
    func testCodeAnonymization() {
        let cleanString = "func sumOfFactors(for number: Int) -> Int {\n\tvar sum = 0\n\tfor i in 1...number {\n\t\tif number % i == 0 {\n\t\t\tsum += i\n\t\t}\n\t}\n\treturn sum\n}\nlet sum = sumOfFactors(for: 100)"

        let anonymizedString = "func #1#(%1%: Int) -> Int {\nvar &1& = 0\nfor @1@ in 1 ... %1% {\nif %1% % @1@ == 0 {\n&1& += @1@\n}\n}\nreturn &1&\n}\nlet &1& = #1#(for: 100)"

        XCTAssertEqual(cleanString.toAnonymizedVariables(), anonymizedString)
    }
}
