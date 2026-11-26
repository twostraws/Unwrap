//
//  UtilityBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Core utility behavior")
struct UtilityBehaviorTests {
    @Test("CountedSet removal is safe and iteration reports every count")
    func countedSetRemovalAndIteration() {
        var countedSet = CountedSet<String>()

        countedSet.remove("missing")
        #expect(countedSet.isEmpty)

        countedSet.insert("swift")
        countedSet.insert("swift")
        countedSet.insert("unwrap")

        let entries = Dictionary(uniqueKeysWithValues: countedSet.map { ($0.key, $0.value) })
        #expect(entries == ["swift": 2, "unwrap": 1])
        #expect(countedSet.count == 2)

        countedSet.remove("swift")
        #expect(countedSet.count(for: "swift") == 1)
        countedSet.remove("swift")
        countedSet.remove("swift")
        #expect(countedSet.contains("swift") == false)
        #expect(countedSet.count == 1)
    }

    @Test("CountedSet survives a Codable round trip")
    func countedSetCodableRoundTrip() throws {
        var original = CountedSet<Int>()
        original.insert(10)
        original.insert(10)
        original.insert(20)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CountedSet<Int>.self, from: data)
        let entries = Dictionary(uniqueKeysWithValues: decoded.map { ($0.key, $0.value) })

        #expect(entries == [10: 2, 20: 1])
        #expect(decoded.count == 2)
        #expect(decoded.count(for: 10) == 2)
        #expect(decoded.count(for: 20) == 1)
        #expect(decoded.count(for: 30) == 0)
    }

    @Test("Small string helpers preserve filename and line behavior")
    func stringHelpers() {
        #expect("".lines == [""])
        #expect("one\ntwo\n".lines == ["one", "two", ""])
        #expect("This?is , a:test'".bundleName == "thisis--atest")
    }

    @Test("Native placeholder filters handle words, graphemes, and unknown filters")
    func placeholderFilters() {
        let resolver = PracticePlaceholderResolver(random: SeededRandomSource(seed: 1))

        #expect(resolver.applyingFilter(to: "Swift|count") == "5")
        #expect(resolver.applyingFilter(to: "👩🏽‍💻|count") == "1")
        #expect(resolver.applyingFilter(to: "hello world|capitalized") == "Hello World")
        #expect(resolver.applyingFilter(to: "swift language|capitalizedFirst") == "Swift language")
        #expect(resolver.applyingFilter(to: "|capitalizedFirst") == "")
        #expect(resolver.applyingFilter(to: "plain text") == "plain text")
        #expect(resolver.applyingFilter(to: "one|unknown") == "one|unknown")
    }

    @Test("Native placeholder references resolve names and values")
    func placeholderReferences() {
        let resolver = PracticePlaceholderResolver(random: SeededRandomSource(seed: 1))
        let context = PracticePlaceholderResolver.Context(
            names: ["numberOfCars"],
            naturalNames: ["number of cars"],
            values: ["12"],
            operators: []
        )
        let template = "NAME_0; NAME_NATURAL_0|capitalizedFirst; NAME_NATURAL_0|count; VALUE_0"

        #expect(
            resolver.resolveReferences(in: template, context: context)
                == "numberOfCars; Number of cars; 14; 12"
        )
    }

    @Test("Placeholder calculations reject arithmetic overflow")
    func placeholderCalculationOverflow() throws {
        let resolver = PracticePlaceholderResolver(random: SeededRandomSource(seed: 1))
        let overflowingExpressions = [
            "\(Int.max) + 1",
            "\(Int.max) * 2",
            "(-\(Int.max) - 1) / -1",
            "-(-\(Int.max) - 1)"
        ]

        #expect(try resolver.resolve("${2 + 3 * 4}").output == "14")

        for expression in overflowingExpressions {
            do {
                _ = try resolver.resolve("${\(expression)}")
                Issue.record("Overflowing calculation should be rejected: \(expression)")
            } catch let error as PracticeContentError {
                #expect(error == .invalidContent(expression))
            }
        }
    }

    @Test("Regex replacement changes exactly one capture")
    func singleRegexReplacement() {
        let original = "cat cat cat"
        let replaced = original.replacingOne(of: "(cat)", with: "dog")

        #expect(occurrences(of: "dog", in: replaced) == 1)
        #expect(occurrences(of: "cat", in: replaced) == 2)
        #expect("cat".replacingOne(of: "(dog)", with: "bird") == "cat")
    }

    @Test("Regex replacement respects extended Unicode graphemes")
    func unicodeRegexReplacement() {
        let source = "A👩🏽‍💻B"

        #expect(source.replacingOne(of: "(👩🏽‍💻)", with: "Swift") == "ASwiftB")
    }

    private func occurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
    }
}
