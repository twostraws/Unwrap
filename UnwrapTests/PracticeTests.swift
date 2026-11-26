//
//  PracticeTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
@testable import Unwrap

/// Tests that practice activities work correctly.
@Suite("Practice activities", .serialized)
struct PracticeTests {
    enum FreeCodingExercise: CaseIterable {
        case stringComparison
        case evenNumbers
        case countingValues
        case propertyObservers
        case filteringNames
    }

    @Test("Free Coding answer banks preserve their accepted and rejected examples")
    func freeCodingAnswerBanks() {
        for exercise in FreeCodingExercise.allCases {
            switch exercise {
            case .stringComparison:
                checkStringComparisonAnswers()
            case .evenNumbers:
                checkEvenNumberAnswers()
            case .countingValues:
                checkCountingValueAnswers()
            case .propertyObservers:
                checkPropertyObserverAnswers()
            case .filteringNames:
                checkFilteringNameAnswers()
            }
        }
    }
}

extension PracticeTests {
    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    private func checkStringComparisonAnswers() {
        let acceptedAnswers = [
            "func myFunction(input1:String,input2:String) -> Bool{\nreturn input1.lowercased() == input2.lowercased()\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nreturn input1.uppercased() == input2.uppercased()\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nletvar result:Bool = input1.lowercased() == input2.lowercased()\nreturn result\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nletvar result:Bool = input1.uppercased() == input2.uppercased()\nreturn result\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.lowercased() == input2.lowercased(){\nreturn true\n}else{\nreturn false\n}\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.uppercased() == input2.uppercased(){\nreturn true\n}else{\nreturn false\n}\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.lowercased() == input2.lowercased(){\nreturn true\n}\nreturn false\n}",
            "func myFunction(input1:String,input2:String) -> Bool{\nif input1.uppercased() == input2.uppercased(){\nreturn true\n}\nreturn false\n}"
        ]

        let correctAnswers = [
            "func compare(string1 str: String, against other: String) -> Bool {\nreturn str.lowercased() == other.lowercased()\n}",
            "func compare(a: String, b: String) -> Bool {\nreturn a.lowercased() == b.lowercased()\n}",
            "func compare(a1: String, b1: String) -> Bool {\nreturn a1.lowercased() == b1.lowercased()\n}",
            "func checkSame(string1: String, string2: String) -> Bool {\nreturn string1.lowercased() == string2.lowercased()\n}",
            "\nfunc checkIdentical(stringA : String, stringB : String)  ->  Bool  {\n\n\treturn stringA.lowercased()  ==  stringB.lowercased()\n\n}\n",
            "func compare(thing1 :String,thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased(){\nreturn true\n} else {\nreturn false\n}\n}",
            "  func    compare   (_ thing1 :String, _ thing2 : String) -> Bool{\nif thing1.lowercased() == thing2.lowercased() {\nreturn true\n}\nelse\n{\nreturn false\n}\n}",
            "func equalStrings(str1: String, str2: String) -> Bool {\nif str1.lowercased() == str2.lowercased() {\nreturn true\n}\nreturn false\n}",
            "func equalStrings(str1: String, str2: String) -> Bool {\nif str1.lowercased() == str2.lowercased() {\nreturn true\n}\nreturn false\n}\nequalString(str1: \"Hello\", str2: \"hello\")"
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
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(!result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }

    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    private func checkEvenNumberAnswers() {
        let acceptedAnswers = [
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

        let correctAnswers = [
            "let evens = (1...100).filter { someNumber in return someNumber % 2 == 0 }",
            "let evens = (1...100).filter { someNumber in someNumber % 2 == 0 }",
            "let evens = (1...100).filter { return $0 % 2 == 0 }",
            "let evens = (1...100).filter { $0 % 2 == 0 }",
            "let evens = (1...100).filter {\n$0 % 2 == 0 }",
            "let evens = (1...100).filter {\n$0 % 2 == 0\n}",
            "let evens = (1...100).filter {$0 % 2 == 0\n}",
            "let evens = (1...100).filter {\n\t$0 % 2 == 0\n}",
            "let evens = (1...100).filter {\n\n\n\n return $0 % 2 == 0\n\n\n\n\n }",
            "var array:[Int]=[]\nfor i in Range(1...100) {\nif i%2==0 {\narray.append(i)\n}\n}",
            "let evens = (1...100).filter { $0.isMultiple(of: 2) }",
            "let evens = (1...100).filter { number in return number.isMultiple(of: 2) }"
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
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(!result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }
}

extension PracticeTests {
    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    private func checkCountingValueAnswers() {
        let acceptedAnswers = [
            "var total:Int = 0\nfor number in numbers{\nif number == 5{\ntotal += 1\n}\n}\nprint(total)",
            "var total:Int = 0\nfor number in numbers{\nif number == 5{\ntotal = total + 1\n}\n}\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{$0 == 5}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{$0 == 5}.count\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{return $0 == 5}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{return $0 == 5}.count\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{num in return num == 5}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{num in return num == 5}.count\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{num in\nreturn num == 5\n}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{num in\nreturn num == 5\n}.count\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{num in num == 5}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{num in num == 5}.count\nprint(total)",
            "letvar filtered:[Int] = numbers.filter{num in\nnum == 5\n}\nprint(filtered.count)",
            "letvar total:Int = numbers.filter{num in\nnum == 5\n}.count\nprint(total)",
            "var count = 0\nfor index in 0..<numbers.count {\nif numbers[index] == 5 {\ncount += 1\n}\n}\nprint(count)"
        ]

        let correctAnswers = [
            "let counter = numbers.filter{return $0 == 5}.count\nprint(counter)",
            "let count = numbers.filter{return $0 == 5}.count\nprint(count)",
            "let count = numbers.filter({return $0 == 5}).count\nprint(count)",
            "var count = 0\nfor index in 0..<numbers.count {\nif numbers[index] == 5 {\ncount += 1\n}\n}\nprint(count)",
            "var count = 0\nfor index in 0..<numbers.count\n{\nif numbers[index] == 5\n{\ncount += 1\n}\n}\nprint(count)"
        ]

        let wrongAnswers = [
            // This misses an equals sign
            "let counter = numbers.filter{return $0 = 5}.count\nprint(counter)",

            // This mixes named and unnamed closure parameters
            "let count = numbers.filter{number in return $0 == 5}.count\nprint(count)",

            // This doesn't print the result
            "var count = 0\nfor index in 0..<numbers.count {\nif numbers[index] == 5 {\ncount += 1\n}\n}",

            // This changes the counting variable name
            "let count = numbers.filter{return $0 == 5}.count\nprint(count1)",

            // This also changes the counting variable name
            "let count1 = numbers.filter{return $0 == 5}.count\nprint(count)"
        ]

        // Make sure all correct answers assert true.
        for answer in correctAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(!result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }

    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    private func checkPropertyObserverAnswers() {
        let acceptedAnswers = [
            "struct Player {\n\tletvar score: Int {\n\t\tdidSet {\n\t\t\tprint(\"The score is now \\(score)\")\n\t\t}\n\t}\n}",
            "struct Player {\n\tletvar score: Int = 0 {\n\t\tdidSet {\n\t\t\tprint(\"The score is now \\(score)\")\n\t\t}\n\t}\n}",
            "struct Player {\n\tletvar score: Int {\n\t\tdidSet {\n\t\t\tprint(\"The score is now \\(score).\")\n\t\t}\n\t}\n}",
            "struct Player {\n\tletvar score: Int = 0 {\n\t\tdidSet {\n\t\t\tprint(\"The score is now \\(score).\")\n\t\t}\n\t}\n}"
        ]

        let correctAnswers = [
            "struct Player\n{\n\tvar score: Int = 0\n\t{\n\t\tdidSet\n\t\t{\n\t\t\tprint(\"The score is now \\(score)\")\n\t\t}\n\t}\n}"
        ]

        let wrongAnswers = [
            // this has the wrong data type
            "struct Player\n{\n\tvar score: Double = 0\n\t{\n\t\tdidSet\n\t\t{\n\t\t\tprint(\"The score is now \\(score)\")\n\t\t}\n\t}\n}"
        ]

        // Make sure all correct answers assert true.
        for answer in correctAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(!result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }

    /// Compares various correct answers against a known question to make sure Free Coding is stable.
    private func checkFilteringNameAnswers() {
        let acceptedAnswers = [
            "var parsed:[String] = [String]()\nfor name in names {\n\tif name.hasPrefix(\"Terry\") {\n\t\tparsed.append(name)\n\t}\n}",
            "var parsed:[String] = [String]()\nfor name in names {\n\tif name.split(separator: \" \")[0] == \"Terry\" {\n\t\tparsed.append(name)\n\t}\n}",
            "letvar parsed2:[String] = names.filter{return $0.hasPrefix(\"Terry\")}",
            "letvar parsed2:[String] = names.filter{return $0.split(separator: \" \")[0] == \"Terry\"}",
            "letvar parsed3:[String] = names.filter{name in\n\treturn name.hasPrefix(\"Terry\")\n}",
            "letvar parsed3:[String] = names.filter{name in\n\treturn name.split(separator: \" \")[0] == \"Terry\"\n}",
            "letvar parsed2:[String] = names.filter{$0.hasPrefix(\"Terry\")}",
            "letvar parsed2:[String] = names.filter{$0.split(separator: \" \")[0] == \"Terry\"}",
            "letvar parsed3:[String] = names.filter {name in\n\tname.hasPrefix(\"Terry\")\n}",
            "letvar parsed3:[String] = names.filter {name in\n\tname.split(separator: \" \")[0] == \"Terry\"\n}",
            "var result:[String] = [String]()\nfor i in 0..<names.count{\n\tif names[i].hasPrefix(\"Terry\") {\n\t\tresult.append(name)\n\t}\n}\n",
            "var result:[String] = [String]()\nfor i in 0..<names.count{\n\tif names[i].split(separator: \" \")[0] == \"Terry\" {\n\t\tresult.append(name)\n\t}\n}\n"
        ]

        let correctAnswers = [
            "var parsed:[String] = [String]()\nfor name in names {\n\tif name.hasPrefix(\"Terry\") {\n\t\tparsed.append(name)\n\t}\n}",
            "var parsed = [String]()\nfor name in names {\n\tif name.split(separator: \" \").first == \"Terry\" {\n\t\tparsed.append(name)\n\t}\n}",
            "var parsed:[String] = [String]()\nfor name in names {\n\tif name.split(separator: \" \")[0] == \"Terry\" {\n\t\tparsed.append(name)\n\t}\n}",
            "let parsed2 = names.filter{return $0.hasPrefix(\"Terry\")}",
            "let parsed2:[String] = names.filter{return $0.split(separator: \" \").first == \"Terry\"}",
            "let parsed2 = names.filter{return $0.split(separator: \" \")[0] == \"Terry\"}",
            "let parsed3:[String] = names.filter{name in\n\treturn name.hasPrefix(\"Terry\")\n}",
            "let parsed3 = names.filter{name in\n\treturn name.split(separator: \" \").first == \"Terry\"\n}",
            "let parsed3:[String] = names.filter{name in\n\treturn name.split(separator: \" \")[0] == \"Terry\"\n}",
            "let parsed2 = names.filter{$0.hasPrefix(\"Terry\")}",
            "let parsed2:[String] = names.filter{$0.split(separator: \" \").first == \"Terry\"}",
            "let parsed2 = names.filter{$0.split(separator: \" \")[0] == \"Terry\"}",
            "let parsed3:[String] = names.filter {name in\n\tname.hasPrefix(\"Terry\")\n}",
            "let parsed3 = names.filter {name in\n\tname.split(separator: \" \").first == \"Terry\"\n}",
            "let parsed3:[String] = names.filter {name in\n\tname.split(separator: \" \")[0] == \"Terry\"\n}",
            "var result = [String]()\nfor i in 0..<names.count{\n\tif names[i].hasPrefix(\"Terry\") {\n\t\tresult.append(name)\n\t}\n}\n",
            "var result:[String] = [String]()\nfor i in 0..<names.count{\n\tif names[i].split(separator: \" \").first == \"Terry\" {\n\t\tresult.append(name)\n\t}\n}\n",
            "var counted = [String]()\nfor i in 0 ..< names.count {\n\tif names[i].split(separator: \" \")[0] == \"Terry\" {\n\t\tcounted.append(name)\n\t}\n}\n"
        ]

        let wrongAnswers = [
            // this counts from 0 through names.count rather than up to
            "var counted = [String]()\nfor i in 0 ... names.count {\n\tif names[i].split(separator: \" \")[0] == \"Terry\" {\n\t\tcounted.append(name)\n\t}\n}\n",

            // this has the wrong array type
            "var counted = [Int]()\nfor i in 0 ..< names.count {\n\tif names[i].split(separator: \" \")[0] == \"Terry\" {\n\t\tcounted.append(name)\n\t}\n}\n"
        ]

        // Make sure all correct answers assert true.
        for answer in correctAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(result.isCorrect, "This answer should be correct: \(answer)")
        }

        // Make sure all wrong answers assert false.
        for answer in wrongAnswers {
            let result = evaluate(answer, acceptedAnswers: acceptedAnswers)
            #expect(!result.isCorrect, "This answer should be wrong: \(answer).")
        }
    }

    private func evaluate(
        _ answer: String,
        startingCode: String = "",
        acceptedAnswers: [String]
    ) -> FreeCodingEvaluator.Evaluation {
        FreeCodingEvaluator().evaluate(
            answer: answer,
            startingCode: startingCode,
            acceptedAnswers: acceptedAnswers
        )
    }
}
