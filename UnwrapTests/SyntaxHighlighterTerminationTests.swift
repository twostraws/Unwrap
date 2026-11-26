//
//  SyntaxHighlighterTerminationTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

/// Free Coding rehighlights whatever the learner has typed after every edit, so the highlighter
/// has to cope with code that is half-written or contains characters Swift wouldn't accept.
@Suite("Syntax highlighter termination")
struct SyntaxHighlighterTerminationTests {
    @Test(
        "Half-typed and unusual Swift is highlighted without losing any text",
        arguments: [
            "",
            "\"unterminated",
            "\"\"\"\nunterminated multiline",
            "#\"raw",
            "/* unterminated comment",
            "/* nested /* comment */",
            "\\",
            "\"\\",
            "\"\\(",
            "\"\\(name",
            "#",
            "@",
            "$",
            "`",
            "`unterminated",
            "0x",
            "0b",
            "0o",
            "1.",
            "1e",
            "1e+",
            "0x1p",
            "1_000_",
            "..",
            "...",
            "/",
            "let 名前 = \"値\"",
            "let café = 👩🏽‍💻",
            "let total = ٣ + ３",
            "let chapter = Ⅷ",
            "x\u{0301}\u{0}\r\n\t"
        ]
    )
    func awkwardInput(source: String) throws {
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(highlighted.source == source)
        highlighted.validateRanges()
    }

    /// Unicode counts fractions and numerals such as 十 as numbers, but a Swift number literal can
    /// only start with a digit worth 0 through 9. Treating them as the start of a number once left
    /// the scanner unable to advance, which froze the app as soon as one was typed.
    @Test(
        "Numeric characters that aren't decimal digits don't stall highlighting",
        arguments: ["½", "let half = ½", "let ten = 十", "十 + 万", "print(½, 十)", "1½", "x = 3 + ½ // half"]
    )
    func nonDecimalNumerals(source: String) throws {
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)
        let numbers = highlighted.tokens
            .filter { $0.kind == .number }
            .map { String(source[$0.range]) }

        #expect(highlighted.source == source)
        #expect(numbers.allSatisfy { $0.allSatisfy(\.isASCII) }, "Highlighted as numbers: \(numbers)")
        highlighted.validateRanges()
    }
}
