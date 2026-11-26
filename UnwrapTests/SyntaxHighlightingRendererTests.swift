//
//  SyntaxHighlightingRendererTests.swift
//  UnwrapTests
//

import Foundation
import SwiftUI
import Testing
@testable import Unwrap

@MainActor
@Suite("Syntax highlighting renderers")
struct SyntaxHighlightingRendererTests {
    @Test("AttributedString output preserves text and semantic colors")
    func attributedStringOutput() throws {
        let source = "let value = 42 // answer"
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)
        let result = AttributedStringSyntaxRenderer().render(
            highlighted,
            theme: .github,
            variant: .dark
        )
        let palette = SyntaxTheme.github.palette(for: .dark)

        #expect(String(result.characters) == source)

        for token in highlighted.tokens {
            let resultRange = try #require(Range(token.range, in: result))
            #expect(result[resultRange].foregroundColor == palette.style(for: token.kind).swiftUIColor)
            #expect(result[resultRange].font != nil)
        }
    }

    @Test("HTML output escapes hostile code and emits semantic spans")
    func safeHTMLOutput() throws {
        let source = #"let value = "</code><script>alert('x')</script>" && count < 2"#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)
        let html = HTMLSyntaxRenderer().render(
            highlighted,
            theme: .github,
            variant: .light,
            options: SyntaxRenderingOptions(lineWrapping: .enabled)
        )

        #expect(html.contains("<pre"))
        #expect(html.contains("<code class=\"language-swift\">"))
        #expect(html.contains("<span class=\"token keyword\""))
        #expect(html.contains("&lt;/code&gt;&lt;script&gt;"))
        #expect(html.contains("&amp;&amp;"))
        #expect(html.contains("&lt;"))
        #expect(html.contains("<script>") == false)
    }

    @Test("HTML output applies both theme variants")
    func htmlThemes() throws {
        let highlighted = try SyntaxHighlighter().highlight("let value = \"Hello\"", language: .swift)
        let renderer = HTMLSyntaxRenderer()
        let light = renderer.render(highlighted, theme: .xcode, variant: .light)
        let dark = renderer.render(highlighted, theme: .xcode, variant: .dark)

        #expect(light.contains("data-theme=\"xcode\""))
        #expect(light.contains("data-variant=\"light\""))
        #expect(light.contains("#AA0D91"))
        #expect(dark.contains("data-variant=\"dark\""))
        #expect(dark.contains("#FC5FA3"))
        #expect(light != dark)
    }

    @Test("Wrapping is opt-in and never enables hyphenation")
    func wrappingOptions() throws {
        let source = "let exceptionallyLongIdentifierWithoutBreaks = 1"
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)
        let renderer = HTMLSyntaxRenderer()
        let scrolling = renderer.render(
            highlighted,
            theme: .xcode,
            variant: .light,
            options: SyntaxRenderingOptions(lineWrapping: .disabled)
        )
        let wrapping = renderer.render(
            highlighted,
            theme: .xcode,
            variant: .light,
            options: SyntaxRenderingOptions(lineWrapping: .enabled)
        )

        #expect(CodeLineWrapping.disabled.allowsWrapping == false)
        #expect(CodeLineWrapping.enabled.allowsWrapping)
        #expect(CodeLineWrapping.disabled.allowsHyphenation == false)
        #expect(CodeLineWrapping.enabled.allowsHyphenation == false)
        #expect(scrolling.contains("white-space: pre"))
        #expect(scrolling.contains("overflow-x: auto"))
        #expect(wrapping.contains("white-space: pre-wrap"))
        #expect(wrapping.contains("overflow-wrap: anywhere"))
        #expect(wrapping.contains("hyphens: none"))
    }

    @Test("Empty and plain source render without special cases leaking")
    func emptySource() throws {
        let highlighted = try SyntaxHighlighter().highlight("", language: .swift)
        let attributed = AttributedStringSyntaxRenderer().render(
            highlighted,
            theme: .xcode,
            variant: .light
        )
        let html = HTMLSyntaxRenderer().render(highlighted, theme: .xcode, variant: .light)

        #expect(highlighted.tokens.isEmpty)
        #expect(String(attributed.characters).isEmpty)
        #expect(html.contains("<code class=\"language-swift\"></code>"))
    }

    @Test("Repeated highlighting is deterministic and does not retain prior source")
    func deterministicOutput() throws {
        let highlighter = SyntaxHighlighter()
        let renderer = HTMLSyntaxRenderer()
        let firstSource = "let first = \"one\""
        let secondSource = "let second = 2"

        let first = try highlighter.highlight(firstSource, language: .swift)
        _ = try highlighter.highlight(secondSource, language: .swift)
        let repeated = try highlighter.highlight(firstSource, language: .swift)

        #expect(first == repeated)
        #expect(
            renderer.render(first, theme: .github, variant: .dark)
                == renderer.render(repeated, theme: .github, variant: .dark)
        )
    }
}
