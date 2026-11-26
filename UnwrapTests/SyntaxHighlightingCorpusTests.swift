//
//  SyntaxHighlightingCorpusTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@MainActor
@Suite("Syntax highlighting shipped corpus")
struct SyntaxHighlightingCorpusTests {
    @Test("Every shipped tutorial code block survives every native theme variant")
    func everyLessonCodeBlock() throws {
        let highlighter = SyntaxHighlighter()
        let renderer = AttributedStringSyntaxRenderer()
        var blockCount = 0
        var lineCount = 0

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: .main)

            for block in lesson.content.blocks {
                guard case .code(let source) = block else { continue }
                blockCount += 1
                lineCount += source.split(separator: "\n", omittingEmptySubsequences: false).count

                let highlighted = try highlighter.highlight(source, language: .swift)
                #expect(highlighted.source == source, "Changed source in \(lesson.id)")
                highlighted.validateRanges()

                for theme in SyntaxTheme.builtIn {
                    for variant in SyntaxThemeVariant.allCases {
                        let attributed = renderer.render(
                            highlighted,
                            theme: theme,
                            variant: variant
                        )
                        #expect(
                            String(attributed.characters) == source,
                            "Renderer changed source in \(lesson.id)"
                        )
                    }
                }
            }
        }

        #expect(blockCount == 230)
        #expect(lineCount == 790)
    }

    @Test("Every syntax-highlighted review answer survives every native theme variant")
    func everyReviewAnswer() throws {
        let highlighter = SyntaxHighlighter()
        let renderer = AttributedStringSyntaxRenderer()
        var snippetCount = 0
        var lineCount = 0

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: .main)
            guard lesson.review.syntaxHighlighting else { continue }

            for answer in lesson.review.correct + lesson.review.wrong {
                let source = answer.text
                snippetCount += 1
                lineCount += source.split(separator: "\n", omittingEmptySubsequences: false).count

                let highlighted = try highlighter.highlight(source, language: .swift)
                #expect(highlighted.source == source, "Changed review source in \(lesson.id)")
                highlighted.validateRanges()

                for theme in SyntaxTheme.builtIn {
                    for variant in SyntaxThemeVariant.allCases {
                        let attributed = renderer.render(
                            highlighted,
                            theme: theme,
                            variant: variant
                        )
                        #expect(
                            String(attributed.characters) == source,
                            "Renderer changed review source in \(lesson.id)"
                        )
                    }
                }
            }
        }

        #expect(snippetCount == 948)
        #expect(lineCount == 5_190)
    }

    @Test("The complete tutorial corpus is deterministic in one engine session")
    func corpusDeterminism() throws {
        let highlighter = SyntaxHighlighter()
        var firstPass = [HighlightedCode]()

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: .main)

            for block in lesson.content.blocks {
                guard case .code(let source) = block else { continue }
                firstPass.append(try highlighter.highlight(source, language: .swift))
            }
        }

        var index = 0

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: .main)

            for block in lesson.content.blocks {
                guard case .code(let source) = block else { continue }
                #expect(try highlighter.highlight(source, language: .swift) == firstPass[index])
                index += 1
            }
        }

        #expect(index == 230)
    }
}
