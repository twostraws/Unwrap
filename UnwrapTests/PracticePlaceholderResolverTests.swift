//
//  PracticePlaceholderResolverTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

/// Predict the Output and Tap to Code both build their questions and their answers from
/// templates, so a wrong name or value here produces a question whose "correct" answer is wrong.
@Suite("Practice placeholder resolver")
struct PracticePlaceholderResolverTests {
    @Test("An integer declaration records its name and value for later reference", arguments: 0..<50)
    func integerDeclaration(seed: Int) throws {
        let resolution = try resolver(seed: seed).resolve("CONSTANT_OR_VARIABLE RANDOM_INT_NAME = RANDOM_SMALL_INT")
        let match = try #require(resolution.output.wholeMatch(of: #/(let|var) ([a-z][A-Za-z]*) = (\d+)/#))
        let value = try #require(Int(match.3))

        #expect(resolution.context.names == [String(match.2)])
        #expect(resolution.context.naturalNames.count == 1)
        #expect(resolution.context.values == [String(match.3)])
        #expect((1...10).contains(value))
    }

    @Test("Each integer size stays inside its range", arguments: 0..<50)
    func integerRanges(seed: Int) throws {
        let resolution = try resolver(seed: seed).resolve("RANDOM_MEDIUM_INT RANDOM_SMALL_INT RANDOM_TINY_INT")
        let numbers = resolution.output.split(separator: " ").compactMap { Int($0) }

        try #require(numbers.count == 3)
        #expect((1...100).contains(numbers[0]))
        #expect((1...10).contains(numbers[1]))
        #expect((1...3).contains(numbers[2]))
        #expect(resolution.context.values == numbers.map(String.init))
    }

    @Test(
        "Repeating a name placeholder never repeats a name",
        arguments: ["RANDOM_INT_NAME", "RANDOM_STRING_NAME", "RANDOM_BOOL_NAME"]
    )
    func repeatedNamesAreUnique(placeholder: String) throws {
        let template = "\(placeholder) \(placeholder) \(placeholder)"

        for seed in 0..<50 {
            let resolution = try resolver(seed: seed).resolve(template)
            let names = resolution.output.split(separator: " ").map(String.init)

            #expect(Set(names).count == 3, "Seed \(seed) repeated a name: \(names)")
            #expect(resolution.context.names == names)
        }
    }

    @Test("Reusing a string value placeholder gives two different values", arguments: 0..<50)
    func reassignedStringValue(seed: Int) throws {
        // This is the shape of the shipped "assign, then reassign" question, whose answer is VALUE_1.
        let template = "var RANDOM_STRING_NAME = \"RANDOM_STRING_VALUE_0\"\nNAME_0 = \"RANDOM_STRING_VALUE_0\""
        let resolution = try resolver(seed: seed).resolve(template)
        let values = resolution.context.values
        let name = try #require(resolution.context.names.first)

        try #require(values.count == 2)
        #expect(values[0] != values[1])
        #expect(resolution.output == "var \(name) = \"\(values[0])\"\n\(name) = \"\(values[1])\"")
    }

    @Test("Integer values are numbered before string values, wherever they appear")
    func valueNumbering() throws {
        // The shipped ".count" comparison question relies on this: its number is VALUE_0
        // even though the string is written first.
        let template = "\"RANDOM_STRING_VALUE_0\" RANDOM_STRING_NAME RANDOM_SMALL_INT"
        let resolution = try resolver(seed: 11).resolve(template)
        let values = resolution.context.values

        try #require(values.count == 2)
        #expect(Int(values[0]) != nil)
        #expect(resolution.output.hasPrefix("\"\(values[1])\" "))
        #expect(resolution.output.hasSuffix(" \(values[0])"))
    }

    @Test("A string name with no value placeholder still records a value to refer to")
    func implicitStringValue() throws {
        let resolution = try resolver(seed: 12).resolve("RANDOM_STRING_NAME")

        #expect(resolution.context.names == [resolution.output])
        #expect(resolution.context.values.count == 1)
        #expect(resolution.context.values.first?.isEmpty == false)
    }

    @Test(
        "A string value with no matching string name is invalid content",
        arguments: ["RANDOM_STRING_VALUE_0", "RANDOM_STRING_NAME = RANDOM_STRING_VALUE_1"]
    )
    func unmatchedStringValue(template: String) {
        #expect(throws: PracticeContentError.self) {
            try resolver(seed: 13).resolve(template)
        }
    }

    @Test("Booleans, storage keywords, and operators come from their fixed vocabularies")
    func fixedVocabularies() throws {
        var storage = Set<String>()
        var booleans = Set<String>()
        var operators = Set<String>()

        for seed in 0..<100 {
            let resolution = try resolver(seed: seed).resolve("CONSTANT_OR_VARIABLE TRUE_OR_FALSE RANDOM_OPERATOR")
            let parts = resolution.output.split(separator: " ").map(String.init)

            try #require(parts.count == 3)
            storage.insert(parts[0])
            booleans.insert(parts[1])
            operators.insert(parts[2])
            #expect(resolution.context.operators == [parts[2]])
        }

        #expect(storage == ["let", "var"])
        #expect(booleans == ["true", "false"])
        #expect(operators == ["<", ">", "<=", ">=", "==", "!="])
    }

    @Test("A later template can refer back to names and values from an earlier one")
    func contextCarriesBetweenTemplates() throws {
        let resolver = resolver(seed: 14)
        let code = try resolver.resolve("let RANDOM_INT_NAME = RANDOM_TINY_INT")
        let name = try #require(code.context.names.first)
        let naturalName = try #require(code.context.naturalNames.first)
        let value = try #require(code.context.values.first.flatMap { Int($0) })

        let answer = try resolver.resolve(
            "NAME_0 is VALUE_0, doubled is ${VALUE_0 * 2}, called NAME_NATURAL_0|capitalized",
            context: code.context
        )

        #expect(answer.output == "\(name) is \(value), doubled is \(value * 2), called \(naturalName.capitalized)")
        #expect(answer.context == code.context)
    }

    @Test(
        "Calculations follow precedence, grouping, and negation",
        arguments: [
            ("${2 + 3 * 4}", "14"),
            ("${(2 + 3) * 4}", "20"),
            ("${10 - 4 - 3}", "3"),
            ("${7 / 2}", "3"),
            ("${7 % 4}", "3"),
            ("${-3 + 5}", "2"),
            ("${2 * -3}", "-6"),
            ("${ 12 }", "12"),
            ("${((1 + 2) * (3 + 4)) % 5}", "1"),
            ("Even: ${4 % 2}, odd: ${5 % 2}", "Even: 0, odd: 1"),
            ("No calculation here", "No calculation here")
        ]
    )
    func calculations(template: String, expected: String) throws {
        #expect(try resolver(seed: 15).resolve(template).output == expected)
    }

    @Test(
        "Malformed calculations are reported rather than shown to the learner",
        arguments: ["1 +", "(1 + 2", "1 + 2)", "1 / 0", "5 % 0", "two", "1 2", "3 ** 2"]
    )
    func malformedCalculations(calculation: String) {
        #expect(throws: PracticeContentError.invalidContent(calculation)) {
            try resolver(seed: 16).resolve("${\(calculation)}")
        }
    }

    private func resolver(seed: Int) -> PracticePlaceholderResolver {
        PracticePlaceholderResolver(random: SeededRandomSource(seed: UInt64(seed)))
    }
}
