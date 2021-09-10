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
        let cleanString1 = "func sumOfFactors(for number: Int) -> Int {\n\tvar sum = 0\n\tfor i in 1...number {\n\t\tif number % i == 0 {\n\t\t\tsum += i\n\t\t}\n\t}\n\treturn sum\n}\nlet sum = sumOfFactors(for: 100)"

        let anonymizedString1 = "func #1#(%1%: Int) -> Int {\nvar &1& = 0\nfor @1@ in 1 ... %1% {\nif %1% % @1@ == 0 {\n&1& += @1@\n}\n}\nreturn &1&\n}\nlet &1& = #1#(for: 100)"

        XCTAssertEqual(cleanString1.toAnonymizedVariables(), anonymizedString1)

        // watch out for Pythonic ranges
        let cleanString2 = "for i in Range(1...100) {"
        let anonymizedString2 = "for @1@ in 1 ... 100 {"
        XCTAssertEqual(cleanString2.toAnonymizedVariables(), anonymizedString2)

        // watch out for ranges in parens
        let cleanString3 = "for i in (1...100) {"
        let anonymizedString3 = "for @1@ in 1 ... 100 {"
        XCTAssertEqual(cleanString3.toAnonymizedVariables(), anonymizedString3)

        // watch out for explicit type annotation with an empty array initializer
        let cleanString4 = "var array:[Int]=[]"
        let anonymizedString4 = "var &1& = [Int]()"
        XCTAssertEqual(cleanString4.toAnonymizedVariables(), anonymizedString4)

        // check that a simple (albeit bad) function definition doesn't cause problems
        let cleanString5 = "func a"
        let anonymizedString5 = "func #1#"
        XCTAssertEqual(cleanString5.toAnonymizedVariables(), anonymizedString5)
        
        // watch out for ellipsis '…' character
        let cleanString6 = "…"
        let anonymizedString6 = " ... "
        XCTAssertEqual(cleanString6.toAnonymizedVariables(), anonymizedString6)
    }

    /// Tests that a optionalreturn keyword work properly.
    func testSolveOptionalReturnStatements() {
        let cleanString1 = "    optionalreturn   "
        let homogenizedString1 = " "
        XCTAssertEqual(cleanString1.solveOptionalReturnStatements(), homogenizedString1)

        let cleanString2 = "optionalreturn   "
        let homogenizedString2 = " "
        XCTAssertEqual(cleanString2.solveOptionalReturnStatements(), homogenizedString2)

        let cleanString3 = "    optionalreturn"
        let homogenizedString3 = " "
        XCTAssertEqual(cleanString3.solveOptionalReturnStatements(), homogenizedString3)

        let cleanString4 = "optionalreturn"
        let homogenizedString4 = " "
        XCTAssertEqual(cleanString4.solveOptionalReturnStatements(), homogenizedString4)

        let cleanString5 = " optionalreturn"
        let homogenizedString5 = " "
        XCTAssertEqual(cleanString5.solveOptionalReturnStatements(), homogenizedString5)

        let cleanString6 = "optionalreturn "
        let homogenizedString6 = " "
        XCTAssertEqual(cleanString6.solveOptionalReturnStatements(), homogenizedString6)

        let cleanString7 = " optionalreturn "
        let homogenizedString7 = " "
        XCTAssertEqual(cleanString7.solveOptionalReturnStatements(), homogenizedString7)

        let cleanString8 = "\n    optionalreturn   "
        let homogenizedString8 = " "
        XCTAssertEqual(cleanString8.solveOptionalReturnStatements(), homogenizedString8)

        let cleanString9 = "\noptionalreturn   "
        let homogenizedString9 = " "
        XCTAssertEqual(cleanString9.solveOptionalReturnStatements(), homogenizedString9)

        let cleanString10 = "\n    optionalreturn"
        let homogenizedString10 = " "
        XCTAssertEqual(cleanString10.solveOptionalReturnStatements(), homogenizedString10)

        let cleanString11 = "\noptionalreturn"
        let homogenizedString11 = " "
        XCTAssertEqual(cleanString11.solveOptionalReturnStatements(), homogenizedString11)

        let cleanString12 = "\n optionalreturn"
        let homogenizedString12 = " "
        XCTAssertEqual(cleanString12.solveOptionalReturnStatements(), homogenizedString12)

        let cleanString13 = "\noptionalreturn "
        let homogenizedString13 = " "
        XCTAssertEqual(cleanString13.solveOptionalReturnStatements(), homogenizedString13)

        let cleanString14 = "\n optionalreturn "
        let homogenizedString14 = " "
        XCTAssertEqual(cleanString14.solveOptionalReturnStatements(), homogenizedString14)

        // this is a negative test
        let cleanString15 = " optinalreturn "
        let homogenizedString15 = " "
        XCTAssertNotEqual(cleanString15.solveOptionalReturnStatements(), homogenizedString15)

        let cleanString16 = "func myFunction(input1:String,input2:String) -> Bool{\n optionalreturn input1.lowercased() == input2.lowercased()\n}"
        let homogenizedString16 = "func myFunction(input1:String,input2:String) -> Bool{\n input1.lowercased() == input2.lowercased()\n}"
        XCTAssertEqual(cleanString16.solveOptionalReturnStatements(), homogenizedString16)

        let cleanString17 = "func myFunction(input1:String,input2:String) -> Bool{\noptionalreturn input1.lowercased() == input2.lowercased()\n}"
        let homogenizedString17 = "func myFunction(input1:String,input2:String) -> Bool{\n input1.lowercased() == input2.lowercased()\n}"
        XCTAssertEqual(cleanString17.solveOptionalReturnStatements(), homogenizedString17)

        let cleanString18 = "func myFunction(input1:String,input2:String) -> Bool{optionalreturn input1.lowercased() == input2.lowercased()}"
        let homogenizedString18 = "func myFunction(input1:String,input2:String) -> Bool{ input1.lowercased() == input2.lowercased()}"
        XCTAssertEqual(cleanString18.solveOptionalReturnStatements(), homogenizedString18)

        let cleanString19 = "func myFunction(input1:String,input2:String) -> Bool{ optionalreturn input1.lowercased() == input2.lowercased() }"
        let homogenizedString19 = "func myFunction(input1:String,input2:String) -> Bool{ input1.lowercased() == input2.lowercased() }"
        XCTAssertEqual(cleanString19.solveOptionalReturnStatements(), homogenizedString19)
    }

    func testHomogenizeGuardStatements() {
        let cleanString1 = "guard s==a else { \n return                \n  }\nreturn somethingelse\n}"
        let homogenizedString1 = "guard s==a else { return }\nreturn somethingelse\n}"
        XCTAssertEqual(cleanString1.homogenizeGuardStatements(), homogenizedString1)

        let cleanString2 = "guardinput1else {  \n return              something       \n   }\nreturn somethingelse\n}"
        let homogenizedString2 = "guardinput1else { return something }\nreturn somethingelse\n}"
        XCTAssertEqual(cleanString2.homogenizeGuardStatements(), homogenizedString2)

        let cleanString3 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else {  \n return              something       \n   }\nreturn false\n}"
        let homogenizedString3 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else { return something }\nreturn false\n}"
        XCTAssertEqual(cleanString3.homogenizeGuardStatements(), homogenizedString3)

        let cleanString4 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else {  \n return        \n   }\nreturn false\n}"
        let homogenizedString4 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() != input2.uppercased() else { return }\nreturn false\n}"
        XCTAssertEqual(cleanString4.homogenizeGuardStatements(), homogenizedString4)

        let cleanString5 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() !=&|\n input2.uppercased() else {\nreturn true\n}\nreturn false\n}"
        let homogenizedString5 = "func myFunction(input1:String,input2:String) -> Bool{\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
        XCTAssertEqual(cleanString5.homogenizeGuardStatements(), homogenizedString5)

        let cleanString6 = "func myFunction(input1:String,input2:String) -> Bool{\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {\nreturn true\n}\nreturn false\n}"
        let homogenizedString6 = "func myFunction(input1:String,input2:String) -> Bool{\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
        XCTAssertEqual(cleanString6.homogenizeGuardStatements(), homogenizedString6)

        let cleanString7 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n return                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return true \n }\nreturn false\n}"
        let homogenizedString7 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { return }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
        XCTAssertEqual(cleanString7.homogenizeGuardStatements(), homogenizedString7)

        let cleanString8 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n return                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return  \n }\nreturn false\n}"
        let homogenizedString8 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { return }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return }\nreturn false\n}"
        XCTAssertEqual(cleanString8.homogenizeGuardStatements(), homogenizedString8)

        let cleanString9 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return  \n }\nreturn false\n}"
        let homogenizedString9 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return }\nreturn false\n}"
        XCTAssertEqual(cleanString9.homogenizeGuardStatements(), homogenizedString9)

        let cleanString10 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\n}"
        let homogenizedString10 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
        XCTAssertEqual(cleanString10.homogenizeGuardStatements(), homogenizedString10)

        let cleanString11 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\nguard s==a else { \n     continue                \n  }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else {  \n   return    true   \n }\nreturn false\n}"
        let homogenizedString11 = "func myFunction(input1:String,input2:String) -> Bool{\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\nguard s==a else { continue }\nif number == 8 {\nprint()\n} else {\nprint(\"something\")\n}\nguard input1.uppercased() !=&|\n input2.uppercased() else { return true }\nreturn false\n}"
        XCTAssertEqual(cleanString11.homogenizeGuardStatements(), homogenizedString11)
    }
}
