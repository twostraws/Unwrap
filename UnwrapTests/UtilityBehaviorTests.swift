//
//  UtilityBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
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
        #expect(!countedSet.contains("swift"))
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

    @Test("lineDiff handles equal strings, changed lines, and unequal line counts")
    func lineDifferences() {
        #expect("".lineDiff(from: "") == -1)
        #expect("same".lineDiff(from: "same") == -1)
        #expect("first\nsecond".lineDiff(from: "changed\nsecond") == 0)
        #expect("first\nsecond".lineDiff(from: "first\nchanged") == 1)
        #expect("same".lineDiff(from: "same\nextra") == 1)
        #expect("same\nextra".lineDiff(from: "same") == 1)
        #expect("same\n".lineDiff(from: "same") == 1)
    }

    @Test("Small string helpers preserve their documented behavior")
    func stringHelpers() {
        #expect("".lines == [""])
        #expect("one\ntwo\n".lines == ["one", "two", ""])

        #expect("Andrew".startsWithVowel)
        #expect("URSULA".startsWithVowel)
        #expect(!"Swift".startsWithVowel)
        #expect(!"".startsWithVowel)

        let source = "\\(name) -> String"
        let expected = "\\\u{2060}(name) -\u{2060}> String"
        #expect(source.fixingLineWrapping() == expected)

        #expect("Number of cars".formatAsVariable() == "numberOfCars")
        #expect("This?is , a:test'".bundleName == "thisis--atest")
    }

    @Test("Placeholder filters handle words, graphemes, and absent filters")
    func placeholderFilters() {
        #expect("Swift".applyingFilter("count") == "5")
        #expect("👩🏽‍💻".applyingFilter("count") == "1")
        #expect("hello world".applyingFilter("capitalized") == "Hello World")
        #expect("swift language".applyingFilter("capitalizedFirst") == "Swift language")
        #expect("".applyingFilter("capitalizedFirst") == "")

        #expect("hello world|capitalized".resolvingFilters() == "Hello World")
        #expect("plain text".resolvingFilters() == "plain text")
        #expect("one|two|three".resolvingFilters() == "one|two|three")
    }

    @Test("NSRange substring conversion respects extended Unicode graphemes")
    func unicodeSubstring() {
        let source = "A👩🏽‍💻B"
        let expected = "👩🏽‍💻"
        let range = (source as NSString).range(of: expected)

        #expect(source.substring(at: range) == expected)
    }

    @Test("Regex replacement changes exactly one capture")
    func singleRegexReplacement() {
        let original = "cat cat cat"
        let replaced = original.replacingOne(of: "(cat)", with: "dog")

        #expect(occurrences(of: "dog", in: replaced) == 1)
        #expect(occurrences(of: "cat", in: replaced) == 2)
        #expect("cat".replacingOne(of: "(dog)", with: "bird") == "cat")
    }

    @Test("HTML wrappers resolve style, width, and image substitutions")
    func bundleWrapperSubstitutions() throws {
        let width: CGFloat = 347
        let resourceURL = try #require(Bundle.main.resourceURL)
        let full = String.wrapperHTML(width: width)
        let slim = String.wrapperHTML(width: width, slimLayout: true)

        for wrapper in [full, slim] {
            #expect(!wrapper.contains("[STYLE]"))
            #expect(!wrapper.contains("[FONTSIZE]"))
            #expect(!wrapper.contains("[IMAGEWIDTH]"))
            #expect(wrapper.contains("\(width)px"))
            #expect(wrapper.contains("[BODY]"))
        }

        #expect(full.contains("playVideo"))
        #expect(full.contains("<img src=\"\(resourceURL)/"))
        #expect(!slim.contains("playVideo"))
        #expect(!slim.contains("<img src="))
    }

    private func occurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
    }
}
