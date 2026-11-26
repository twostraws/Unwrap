//
//  SwiftCodeHighlighterTests.swift
//  UnwrapTests
//

import Foundation
import SwiftUI
import Testing
@testable import Unwrap

@Suite("Swift code highlighter")
struct SwiftCodeHighlighterTests {
    @Test("Highlighter preserves source text and applies semantic attributes")
    func highlightedAttributes() throws {
        let source = "let value = 10 // Example\nprint(\"Hello\")"
        let result = SwiftCodeHighlighter().attributedString(for: source, colorScheme: .light)

        #expect(String(result.characters) == source)

        for run in result.runs {
            #expect(run.font != nil)
        }

        let expectedColors = [
            "let": Color(red: 170.0 / 255.0, green: 13.0 / 255.0, blue: 145.0 / 255.0),
            "value": Color(red: 63.0 / 255.0, green: 110.0 / 255.0, blue: 116.0 / 255.0),
            "10": Color(red: 28.0 / 255.0, green: 0.0, blue: 207.0 / 255.0),
            "// Example": Color(red: 0.0, green: 116.0 / 255.0, blue: 0.0),
            "\"Hello\"": Color(red: 196.0 / 255.0, green: 26.0 / 255.0, blue: 22.0 / 255.0)
        ]

        for (text, color) in expectedColors {
            let range = try #require(result.range(of: text))
            #expect(result[range].foregroundColor == color, "Unexpected color for \(text)")
        }
    }

    @Test("Answer feedback replaces every syntax color while preserving source and font")
    func feedbackForegroundColor() {
        let source = "let value = 10 // Example\nprint(\"Hello\")"
        let highlighter = SwiftCodeHighlighter()

        for colorScheme in [ColorScheme.light, .dark] {
            let result = highlighter.attributedString(
                for: source,
                colorScheme: colorScheme,
                foregroundColor: .white
            )

            #expect(String(result.characters) == source)
            for run in result.runs {
                #expect(run.foregroundColor == .white)
                #expect(run.font != nil)
            }
        }
    }

    @Test("Highlighter preserves every shipped lesson code block")
    func shippedLessonCorpus() throws {
        let highlighter = SwiftCodeHighlighter()
        var blockCount = 0
        var lineCount = 0

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: .main)

            for block in lesson.content.blocks {
                guard case .code(let source) = block else { continue }
                blockCount += 1
                lineCount += source.split(separator: "\n", omittingEmptySubsequences: false).count

                for colorScheme in [ColorScheme.light, .dark] {
                    let result = highlighter.attributedString(
                        for: source,
                        colorScheme: colorScheme
                    )
                    #expect(
                        String(result.characters) == source,
                        "Highlighting changed code in \(lesson.id)"
                    )
                }
            }
        }

        #expect(blockCount == 230)
        #expect(lineCount == 790)
    }
}
