//
//  SyntaxHighlighterRobustnessTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@MainActor
@Suite("Syntax highlighter robustness")
struct SyntaxHighlighterRobustnessTests {
    @Test("Swift distinguishes comment lookalikes, strings, and division")
    func swiftLiteralBoundaries() throws {
        let source = #"let url = "https://example.com/*literal*/"; let quotient = 8 / 2 // actual"#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: #""https://example.com/*literal*/""#) == .string)
        #expect(try highlighted.tokenKind(for: "// actual") == .comment)
        #expect(highlighted.tokens.contains { $0.kind == .operator && source[$0.range] == "/" })
        highlighted.validateRanges()
    }

    @Test("JavaScript supports templates, regex flags, and nullish coalescing")
    func javascriptModernLiterals() throws {
        let source = #"const template = `https://${host}/path`; const matcher = /user-[a-z/]+/giu; const value = input ?? "/* literal */";"#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .javascript)

        #expect(try highlighted.tokenKind(for: "`https://${host}/path`") == .string)
        #expect(try highlighted.tokenKind(for: "/user-[a-z/]+/giu") == .regex)
        #expect(try highlighted.tokenKind(for: "??") == .operator)
        #expect(try highlighted.tokenKind(for: #""/* literal */""#) == .string)
        highlighted.validateRanges()
    }

    @Test("JavaScript distinguishes expression-position regexes from postfix division")
    func javascriptRegexContext() throws {
        let source = #"""
        function matcher() {
            return /user-[a-z]+/giu
        }

        const compact = () => /\s+/.test(value)
        const quotient = counter++ / total
        """#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .javascript)

        #expect(try highlighted.tokenKind(for: "/user-[a-z]+/giu") == .regex)
        #expect(try highlighted.tokenKind(for: "/\\s+/") == .regex)
        #expect(
            highlighted.tokens.contains {
                $0.kind == .operator && source[$0.range] == "/"
            }
        )
        highlighted.validateRanges()
    }

    @Test("Python recognizes decorators and combined formatted raw strings")
    func pythonModernStrings() throws {
        let source = #"""
        @cache
        async def render(value):
            return fr"""value {value}
        next""" if value is not None else None
        """#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .python)
        let formattedRawString = "fr\"\"\"value {value}\nnext\"\"\""

        #expect(try highlighted.tokenKind(for: "@cache") == .attribute)
        #expect(try highlighted.tokenKind(for: "async") == .keyword)
        #expect(try highlighted.tokenKind(for: "def") == .keyword)
        #expect(try highlighted.tokenKind(for: formattedRawString) == .string)
        #expect(try highlighted.tokenKind(for: "None") == .keyword)
        highlighted.validateRanges()
    }

    @Test("C++ directives and custom-delimited raw strings remain intact")
    func cppRawStrings() throws {
        let source = ##"""
        #include <string>
        auto value = R"tag(first line
        "quoted")tag";
        """##
        let highlighted = try SyntaxHighlighter().highlight(source, language: .cpp)
        let rawString = "R\"tag(first line\n\"quoted\")tag\""

        #expect(try highlighted.tokenKind(for: "#include") == .directive)
        #expect(try highlighted.tokenKind(for: rawString) == .string)
        highlighted.validateRanges()
    }

    @Test("C# verbatim interpolated strings include doubled quotes")
    func cSharpVerbatimStrings() throws {
        let source = ##"var message = $@"Path {root}\folder ""quoted""";"##
        let highlighted = try SyntaxHighlighter().highlight(source, language: .cSharp)

        #expect(try highlighted.tokenKind(for: "var") == .keyword)
        #expect(try highlighted.tokenKind(for: ##"$@"Path {root}\folder ""quoted""""##) == .string)
        highlighted.validateRanges()
    }

    @Test("Rust preserves nested comments and arbitrary-hash raw strings")
    func rustNestedConstructs() throws {
        let source = ##"""
        /* outer /* nested */ finished */
        let value = r###"raw "quotes" and # marks"###;
        parse(value)?;
        """##
        let highlighted = try SyntaxHighlighter().highlight(source, language: .rust)

        #expect(try highlighted.tokenKind(for: "/* outer /* nested */ finished */") == .comment)
        #expect(try highlighted.tokenKind(for: "r###\"raw \"quotes\" and # marks\"###") == .string)
        #expect(try highlighted.tokenKind(for: "?") == .operator)
        highlighted.validateRanges()
    }

    @Test("Lua long comments take precedence over their line-comment prefix")
    func luaLongComments() throws {
        let source = """
        --[[ first line
        second line ]]
        local enabled = true
        """
        let highlighted = try SyntaxHighlighter().highlight(source, language: .lua)

        #expect(try highlighted.tokenKind(for: "--[[ first line\nsecond line ]]") == .comment)
        #expect(try highlighted.tokenKind(for: "true") == .boolean)
        highlighted.validateRanges()
    }

    @Test("C# and Scala booleans use the shared boolean semantic token")
    func cSharpAndScalaBooleans() throws {
        let highlighter = SyntaxHighlighter()

        for language in [SyntaxLanguage.cSharp, .scala] {
            let highlighted = try highlighter.highlight("let enabled = true; let disabled = false", language: language)

            #expect(try highlighted.tokenKind(for: "true") == .boolean)
            #expect(try highlighted.tokenKind(for: "false") == .boolean)
            highlighted.validateRanges()
        }
    }

    @Test("Markup, CSS, and Markdown keep their structural roles")
    func documentLanguages() throws {
        let highlighter = SyntaxHighlighter()
        let markup = try highlighter.highlight(
            "<!-- note --><button data-id=\"save\">Save</button>",
            language: .markup
        )
        let css = try highlighter.highlight(
            ".button { --accent: #0a84ff; color: var(--accent); }",
            language: .css
        )
        let markdownSource = "## Title\n```swift\nlet value = 1\n```"
        let markdown = try highlighter.highlight(markdownSource, language: .markdown)

        #expect(try markup.tokenKind(for: "<!-- note -->") == .comment)
        #expect(try markup.tokenKind(for: "button") == .tag)
        #expect(try markup.tokenKind(for: "data-id") == .attribute)
        #expect(try css.tokenKind(for: ".button") == .selector)
        #expect(try css.tokenKind(for: "--accent") == .property)
        #expect(try markdown.tokenKind(for: "## Title") == .title)
        #expect(try markdown.tokenKind(for: "```swift\nlet value = 1\n```") == .code)
    }

    @Test("Shell variables and SQL escaping use language-specific rules")
    func shellAndSQL() throws {
        let highlighter = SyntaxHighlighter()
        let shell = try highlighter.highlight(
            "value=${input:-fallback}; printf '%s\\n' \"$value\"",
            language: .bash
        )
        let sql = try highlighter.highlight(
            "SELECT COALESCE(name, 'it''s missing') FROM users WHERE id = 7;",
            language: .sql
        )

        #expect(try shell.tokenKind(for: "${input:-fallback}") == .variable)
        #expect(try shell.tokenKind(for: "printf") == .builtin)
        #expect(try sql.tokenKind(for: "SELECT") == .keyword)
        #expect(try sql.tokenKind(for: "COALESCE") == .builtin)
        #expect(try sql.tokenKind(for: "'it''s missing'") == .string)
        #expect(try sql.tokenKind(for: "7") == .number)
    }

    @Test("CRLF and Unicode remain lossless across representative grammars")
    func unicodeAndCRLF() throws {
        let fixtures: [(SyntaxLanguage, String)] = [
            (.swift, "let café = \"☕️\"\r\nprint(café)"),
            (.python, "def saluer(nom):\r\n    return f\"👋 {nom}\""),
            (.javascript, "const café = \"☕️\";\r\nconsole.log(café);")
        ]

        for (language, source) in fixtures {
            let highlighted = try SyntaxHighlighter().highlight(source, language: language)
            let rendered = AttributedStringSyntaxRenderer().render(
                highlighted,
                theme: .github,
                variant: .dark
            )

            #expect(String(rendered.characters) == source)
            highlighted.validateRanges()
        }
    }

    @Test("Pure highlighting and HTML rendering work away from the main actor")
    func detachedExecution() async throws {
        let result = try await Task.detached {
            let highlighted = try SyntaxHighlighter().highlight(
                "let greeting = \"Hello, \\(name)\"",
                language: .swift
            )
            let html = HTMLSyntaxRenderer().render(
                highlighted,
                theme: .xcode,
                variant: .dark,
                options: SyntaxRenderingOptions(lineWrapping: .enabled)
            )
            return (highlighted, html)
        }.value

        #expect(result.0.source == "let greeting = \"Hello, \\(name)\"")
        #expect(result.1.contains("data-theme=\"xcode\""))
        #expect(result.1.contains("hyphens: none"))
    }
}
