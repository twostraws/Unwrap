//
//  MarkdownTextTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Markdown text")
struct MarkdownTextTests {
    private var bundle: Bundle {
        .main
    }

    @Test("Links and semantic emphasis survive native Markdown conversion")
    func semanticContent() throws {
        let result = MarkdownText.attributedString(
            from: "Plain **bold** *italic* `code` [link](https://example.com/)"
        )
        let boldRange = try #require(range(of: "bold", in: result))
        let italicRange = try #require(range(of: "italic", in: result))
        let codeRange = try #require(range(of: "code", in: result))
        let linkRange = try #require(range(of: "link", in: result))

        #expect(String(result.characters) == "Plain bold italic code link")
        #expect(
            result[boldRange].inlinePresentationIntent?.contains(.stronglyEmphasized) == true
        )
        #expect(result[italicRange].inlinePresentationIntent?.contains(.emphasized) == true)
        #expect(
            result[codeRange].inlinePresentationIntent?.contains(.stronglyEmphasized) == true
        )
        #expect(result[linkRange].link == URL(string: "https://example.com/"))
    }

    @Test("Lesson Markdown uses a monospaced font for inline code")
    func lessonInlineCode() throws {
        let result = LessonMarkdownFormatter.attributedString(
            from: "Use *a value* named `example` from [Swift](https://swift.org/)."
        )
        let emphasisRange = try #require(range(of: "a value", in: result))
        let codeRange = try #require(range(of: "example", in: result))
        let linkRange = try #require(range(of: "Swift", in: result))

        #expect(String(result.characters) == "Use a value named example from Swift.")
        #expect(
            result[emphasisRange].inlinePresentationIntent?.contains(.emphasized) == true
        )
        #expect(result[codeRange].inlinePresentationIntent?.contains(.code) == true)
        #expect(result[codeRange].font != nil)
        #expect(result[linkRange].link == URL(string: "https://swift.org/"))
    }

    @Test("Every shipped native-text string is valid, text-preserving Markdown")
    func shippedMarkdownCorpus() throws {
        let fixtures = try shippedFixtures()
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )

        for fixture in fixtures {
            do {
                let parsed = try AttributedString(markdown: fixture.markdown, options: options)
                #expect(
                    String(parsed.characters) == expectedVisibleText(from: fixture.markdown),
                    "Markdown changed visible text in \(fixture.source)"
                )
            } catch {
                Issue.record("Invalid Markdown in \(fixture.source): \(error)")
            }
        }
    }

    private func shippedFixtures() throws -> [Fixture] {
        let home = try HomeContent(bundle: bundle)
        let glossary = try bundle.decode([LearnGlossaryEntry].self, from: "glossary.json")
        let freeCoding = try bundle.decode([FreeCodingContent].self, from: "FreeCoding.json")
        let rearrangeLines = try bundle.decode(
            [RearrangeLinesContent].self,
            from: "RearrangeTheLines.json"
        )
        let tapToCode = try bundle.decode([TapToCodeContent].self, from: "TapToCode.json")
        var fixtures = [Fixture]()

        func add(_ markdown: String, source: String) {
            guard markdown.isEmpty == false else { return }
            fixtures.append(Fixture(source: source, markdown: markdown))
        }

        add(home.creditsMarkdown, source: "Credits.md")

        for item in home.helpItems {
            add(item.text, source: "Help.json: \(item.title)")
        }

        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: bundle)
            let review = lesson.review
            let source = "\(lesson.id).json"

            for (blockIndex, block) in lesson.content.blocks.enumerated() {
                switch block {
                case .text(let markdown):
                    add(markdown, source: "\(source): content block \(blockIndex)")
                case .bullets(let items), .numbered(let items):
                    for (itemIndex, item) in items.enumerated() {
                        add(
                            item,
                            source: "\(source): content block \(blockIndex), item \(itemIndex)"
                        )
                    }
                case .code:
                    break
                }
            }

            add(review.question, source: "\(source): question")
            add(review.hint, source: "\(source): hint")
            add(review.postscript, source: "\(source): postscript")

            for (index, answer) in (review.correct + review.wrong).enumerated() {
                if review.syntaxHighlighting == false {
                    add(answer.text, source: "\(source): answer \(index)")
                }

                add(answer.reason, source: "\(source): reason \(index)")
            }
        }

        for entry in glossary {
            add(entry.description, source: "glossary.json: \(entry.term)")
        }

        for (index, question) in freeCoding.enumerated() {
            add(question.question, source: "FreeCoding.json: question \(index)")
            add(question.hint, source: "FreeCoding.json: hint \(index)")
        }

        for (index, question) in rearrangeLines.enumerated() {
            add(question.question, source: "RearrangeTheLines.json: question \(index)")
            add(question.hint, source: "RearrangeTheLines.json: hint \(index)")
        }

        for (index, question) in tapToCode.enumerated() {
            add(question.question, source: "TapToCode.json: question \(index)")
        }

        let typeChecker = TypeCheckerQuestionState(random: SeededRandomSource(seed: 1))
        add(typeChecker.prompt, source: "TypeCheckerQuestionState: prompt")
        add(typeChecker.hint, source: "TypeCheckerQuestionState: hint")

        return fixtures
    }

    private func expectedVisibleText(from markdown: String) -> String {
        var result = ""
        var index = markdown.startIndex
        var isInsideCode = false

        while index < markdown.endIndex {
            let character = markdown[index]

            if character == "`" {
                isInsideCode.toggle()
                index = markdown.index(after: index)
                continue
            }

            if isInsideCode == false, markdown[index...].hasPrefix("**") {
                index = markdown.index(index, offsetBy: 2)
                continue
            }

            if isInsideCode == false, character == "*" {
                index = markdown.index(after: index)
                continue
            }

            if isInsideCode == false,
               character == "[",
               let closingBracket = markdown[index...].firstIndex(of: "]") {
                let openingParenthesis = markdown.index(after: closingBracket)

                if openingParenthesis < markdown.endIndex,
                   markdown[openingParenthesis] == "(",
                   let closingParenthesis = markdown[openingParenthesis...].firstIndex(of: ")") {
                    let labelStart = markdown.index(after: index)
                    result += markdown[labelStart..<closingBracket]
                    index = markdown.index(after: closingParenthesis)
                    continue
                }
            }

            result.append(character)
            index = markdown.index(after: index)
        }

        return result
    }

    private func range(
        of substring: String,
        in value: AttributedString
    ) -> Range<AttributedString.Index>? {
        let text = String(value.characters)

        guard let stringRange = text.range(of: substring),
              let lowerBound = AttributedString.Index(stringRange.lowerBound, within: value),
              let upperBound = AttributedString.Index(stringRange.upperBound, within: value) else {
            return nil
        }

        return lowerBound..<upperBound
    }

    private struct Fixture {
        let source: String
        let markdown: String
    }
}
