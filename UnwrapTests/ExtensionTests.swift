//
//  ExtensionTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing

@testable import Unwrap

@Suite("String and date extensions")
struct ExtensionTests {
    nonisolated struct SameDayExpectation {
        let timeInterval: TimeInterval
        let expectedResult: Bool
    }

    nonisolated struct StringBooleanExpectation {
        let input: String
        let expectedResult: Bool
    }

    nonisolated struct StringCountExpectation {
        let input: String
        let expectedCount: Int
    }

    nonisolated struct LineDifferenceExpectation {
        let source: String
        let comparison: String
        let expectedLine: Int
    }

    nonisolated struct StringTransformationExpectation {
        let input: String
        let expectedOutput: String
    }

    private nonisolated enum Fixtures {
        static let sameDayExpectations = [
            SameDayExpectation(timeInterval: 0, expectedResult: true),
            SameDayExpectation(timeInterval: 100_000, expectedResult: false)
        ]

        static let vowelExpectations = [
            StringBooleanExpectation(input: "Andrew", expectedResult: true),
            StringBooleanExpectation(input: "Olivia", expectedResult: true),
            StringBooleanExpectation(input: "ETHAN", expectedResult: true),
            StringBooleanExpectation(input: "URSULA", expectedResult: true),
            StringBooleanExpectation(input: "Chris", expectedResult: false),
            StringBooleanExpectation(input: "CHARLOTTE", expectedResult: false),
            StringBooleanExpectation(input: "Mark", expectedResult: false),
            StringBooleanExpectation(input: "SOPHIE", expectedResult: false)
        ]

        static let lineCountExpectations = [
            StringCountExpectation(input: "Hello", expectedCount: 1),
            StringCountExpectation(input: "Hello\nworld", expectedCount: 2),
            StringCountExpectation(input: "Hello\ndarkness\nmy\nold\nfriend", expectedCount: 5)
        ]

        static let lineDifferenceExpectations = [
            LineDifferenceExpectation(
                source: "This\nis\na\ntest",
                comparison: "This\nis\na\nmess",
                expectedLine: 3
            ),
            LineDifferenceExpectation(
                source: "This\nis\na\ntest",
                comparison: "This\nis\na\ntest",
                expectedLine: -1
            )
        ]

        static let variableFormattingExpectations = [
            StringTransformationExpectation(
                input: "Number of cars", expectedOutput: "numberOfCars"),
            StringTransformationExpectation(
                input: "MY NAME IS INIGO MONTOYA", expectedOutput: "myNameIsInigoMontoya"),
            StringTransformationExpectation(
                input: "You Fight Like A Dairy Farmer", expectedOutput: "youFightLikeADairyFarmer")
        ]

        static let anonymizationExpectations = [
            StringTransformationExpectation(
                input:
                    "func sumOfFactors(for number: Int) -> Int {\n\tvar sum = 0\n\tfor i in 1...number {\n\t\tif number % i == 0 {\n\t\t\tsum += i\n\t\t}\n\t}\n\treturn sum\n}\nlet sum = sumOfFactors(for: 100)",
                expectedOutput:
                    "func #1#(%1%: Int) -> Int {\nvar &1& = 0\nfor @1@ in 1 ... %1% {\nif %1% % @1@ == 0 {\n&1& += @1@\n}\n}\nreturn &1&\n}\nlet &1& = #1#(for: 100)"
            ),
            StringTransformationExpectation(
                input: "for i in Range(1...100) {",
                expectedOutput: "for @1@ in 1 ... 100 {"
            ),
            StringTransformationExpectation(
                input: "for i in (1...100) {",
                expectedOutput: "for @1@ in 1 ... 100 {"
            ),
            StringTransformationExpectation(
                input: "var array:[Int]=[]",
                expectedOutput: "var &1& = [Int]()"
            ),
            StringTransformationExpectation(input: "func a", expectedOutput: "func #1#"),
            StringTransformationExpectation(input: "…", expectedOutput: "...")
        ]

        static let optionalReturnExpectations = [
            StringTransformationExpectation(input: "    optionalreturn   ", expectedOutput: " "),
            StringTransformationExpectation(input: "optionalreturn   ", expectedOutput: " "),
            StringTransformationExpectation(input: "    optionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: "optionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: " optionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: "optionalreturn ", expectedOutput: " "),
            StringTransformationExpectation(input: " optionalreturn ", expectedOutput: " "),
            StringTransformationExpectation(input: "\n    optionalreturn   ", expectedOutput: " "),
            StringTransformationExpectation(input: "\noptionalreturn   ", expectedOutput: " "),
            StringTransformationExpectation(input: "\n    optionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: "\noptionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: "\n optionalreturn", expectedOutput: " "),
            StringTransformationExpectation(input: "\noptionalreturn ", expectedOutput: " "),
            StringTransformationExpectation(input: "\n optionalreturn ", expectedOutput: " "),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\n optionalreturn input1.lowercased() == input2.lowercased()\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\n input1.lowercased() == input2.lowercased()\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\noptionalreturn input1.lowercased() == input2.lowercased()\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\n input1.lowercased() == input2.lowercased()\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{optionalreturn input1.lowercased() == input2.lowercased()}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{ input1.lowercased() == input2.lowercased()}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{ optionalreturn input1.lowercased() == input2.lowercased() }",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{ input1.lowercased() == input2.lowercased() }"
            )
        ]

        static let guardStatementExpectations = [
            StringTransformationExpectation(
                input: "guard s==a else { \n return                \n  }\nreturn somethingelse\n}",
                expectedOutput: "guard s==a else { return }\nreturn somethingelse\n}"
            ),
            StringTransformationExpectation(
                input:
                    "guardinput1else {  \n return              something       \n   }\nreturn somethingelse\n}",
                expectedOutput: "guardinput1else { return something }\nreturn somethingelse\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else {  \n return              something       \n   }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else { return something }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else {  \n return        \n   }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else { return }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() !=&|\n input2.uppercased() else {\nreturn true\n}\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {\nreturn true\n}\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n return                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return true \n }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { return }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n return                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return  \n }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { return }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return  \n }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
            ),
            StringTransformationExpectation(
                input:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\n}",
                expectedOutput:
                    "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
            )
        ]
    }

    @Test("Same-day detection", arguments: Fixtures.sameDayExpectations)
    func sameDay(expectation: SameDayExpectation) {
        let date = Date(timeIntervalSinceReferenceDate: 750_000_000)
        let comparison = date.addingTimeInterval(expectation.timeInterval)

        #expect(date.isSameDay(as: comparison) == expectation.expectedResult)
    }

    @Test("Day differences from one through ten", arguments: 1...10)
    func daysBetween(dayCount: Int) throws {
        let date = Date(timeIntervalSinceReferenceDate: 750_000_000)
        let futureDate = try #require(
            Calendar.current.date(byAdding: .day, value: dayCount, to: date))

        #expect(date.days(between: futureDate) == dayCount)
    }

    @Test("Starting-vowel detection", arguments: Fixtures.vowelExpectations)
    func vowels(expectation: StringBooleanExpectation) {
        #expect(expectation.input.startsWithVowel == expectation.expectedResult)
    }

    @Test("Splitting strings into lines", arguments: Fixtures.lineCountExpectations)
    func stringLines(expectation: StringCountExpectation) {
        #expect(expectation.input.lines.count == expectation.expectedCount)
    }

    @Test("Finding the first different line", arguments: Fixtures.lineDifferenceExpectations)
    func lineDifference(expectation: LineDifferenceExpectation) {
        #expect(
            expectation.source.lineDiff(from: expectation.comparison) == expectation.expectedLine)
    }

    @Test("Formatting variable names", arguments: Fixtures.variableFormattingExpectations)
    func variableFormatting(expectation: StringTransformationExpectation) {
        #expect(expectation.input.formatAsVariable() == expectation.expectedOutput)
    }

    @Test("Anonymizing and homogenizing code", arguments: Fixtures.anonymizationExpectations)
    func codeAnonymization(expectation: StringTransformationExpectation) {
        #expect(expectation.input.toAnonymizedVariables() == expectation.expectedOutput)
    }

    @Test("Solving optional-return statements", arguments: Fixtures.optionalReturnExpectations)
    func optionalReturnStatements(expectation: StringTransformationExpectation) {
        #expect(expectation.input.solveOptionalReturnStatements() == expectation.expectedOutput)
    }

    @Test("A misspelled optional-return token is not transformed as the keyword")
    func misspelledOptionalReturn() {
        #expect(" optinalreturn ".solveOptionalReturnStatements() != " ")
    }

    @Test("Homogenizing guard statements", arguments: Fixtures.guardStatementExpectations)
    func guardStatements(expectation: StringTransformationExpectation) {
        #expect(expectation.input.homogenizeGuardStatements() == expectation.expectedOutput)
    }
}
