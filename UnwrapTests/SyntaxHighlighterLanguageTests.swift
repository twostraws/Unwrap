//
//  SyntaxHighlighterLanguageTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@MainActor
@Suite("Syntax highlighter languages")
struct SyntaxHighlighterLanguageTests {
    @Test("The curated language catalog is explicit and stable")
    func languageCatalog() {
        let expected: Set<SyntaxLanguage> = [
            .bash, .c, .cpp, .cSharp, .css, .dart, .go, .graphql, .java,
            .javascript, .json, .jsx, .kotlin, .lua, .markdown, .markup,
            .objectiveC, .php, .powershell, .python, .ruby, .rust, .scala,
            .sql, .swift, .tsx, .typescript, .yaml
        ]

        #expect(Set(SyntaxLanguage.bundled) == expected)
        #expect(SyntaxLanguage.bundled.count == expected.count)
    }

    @Test(
        "Common aliases resolve to canonical language identifiers",
        arguments: [
            ("js", SyntaxLanguage.javascript),
            ("ts", .typescript),
            ("html", .markup),
            ("xml", .markup),
            ("sh", .bash),
            ("zsh", .bash),
            ("py", .python),
            ("rb", .ruby),
            ("objc", .objectiveC),
            ("cs", .cSharp),
            ("yml", .yaml),
            ("md", .markdown),
            ("ps1", .powershell),
            ("gql", .graphql)
        ]
    )
    func aliases(alias: String, expected: SyntaxLanguage) {
        #expect(SyntaxLanguage.resolve(alias) == expected)
    }

    @Test("Unknown languages fail clearly")
    func unsupportedLanguage() throws {
        let highlighter = SyntaxHighlighter()

        #expect(throws: SyntaxHighlightingError.unsupportedLanguage("brainfuck")) {
            try highlighter.highlight("++++", languageIdentifier: "brainfuck")
        }
    }

    @Test("Callers can register a clearly identified future language")
    func customLanguageGrammar() throws {
        let language = SyntaxLanguage(rawValue: "fixture-language")
        let highlighter = SyntaxHighlighter(
            additionalGrammars: [language: FixtureSyntaxGrammar()]
        )
        let highlighted = try highlighter.highlight(
            "custom source",
            languageIdentifier: "fixture-language"
        )

        #expect(highlighter.registeredLanguages.contains(language))
        #expect(highlighted.language == language)
        #expect(try highlighted.tokenKind(for: "custom source") == .code)
    }

    @Test("Every bundled language produces useful semantic tokens")
    func bundledLanguageFixtures() throws {
        let fixtures = [
            SyntaxFixture(
                language: .swift,
                source: "let value = optional ?? \"fallback\"",
                expectations: ["let": .keyword, "??": .operator, "\"fallback\"": .string]
            ),
            SyntaxFixture(
                language: .javascript,
                source: "const greet = (name) => `Hello ${name}`;",
                expectations: ["const": .keyword, "=>": .operator, "`Hello ${name}`": .string]
            ),
            SyntaxFixture(
                language: .typescript,
                source: "interface User { name?: string }",
                expectations: ["interface": .keyword, "string": .builtin]
            ),
            SyntaxFixture(
                language: .jsx,
                source: "const view = <Button disabled={false}>Save</Button>;",
                expectations: ["const": .keyword, "Button": .tag, "false": .boolean]
            ),
            SyntaxFixture(
                language: .tsx,
                source: "const view: React.FC = () => <Button />;",
                expectations: ["const": .keyword, "=>": .operator, "Button": .tag]
            ),
            SyntaxFixture(
                language: .php,
                source: "<?php $value = $request?->user() ?? null; ?>",
                expectations: ["$value": .variable, "??": .operator, "null": .keyword]
            ),
            SyntaxFixture(
                language: .c,
                source: "const char *message = \"Hello\";",
                expectations: ["const": .keyword, "char": .keyword, "\"Hello\"": .string]
            ),
            SyntaxFixture(
                language: .cpp,
                source: "template<typename T> std::optional<T> first();",
                expectations: ["template": .keyword, "typename": .keyword, "first": .function]
            ),
            SyntaxFixture(
                language: .objectiveC,
                source: "@interface Greeter : NSObject\n- (NSString *)message;\n@end",
                expectations: ["@interface": .keyword, "NSString": .className, "@end": .keyword]
            ),
            SyntaxFixture(
                language: .cSharp,
                source: "public async Task<string?> LoadAsync() => value ?? \"none\";",
                expectations: ["public": .keyword, "async": .keyword, "??": .operator]
            ),
            SyntaxFixture(
                language: .rust,
                source: "let value = items.iter().find_map(|item| item.as_ref())?;",
                expectations: ["let": .keyword, "find_map": .function, "?": .operator]
            ),
            SyntaxFixture(
                language: .python,
                source: "async def fetch(value: str | None = None):\n    return value or \"fallback\"",
                expectations: ["async": .keyword, "def": .keyword, "return": .keyword]
            ),
            SyntaxFixture(
                language: .bash,
                source: "for file in \"$@\"; do printf '%s\\n' \"${file:-missing}\"; done",
                expectations: ["for": .keyword, "do": .keyword, "done": .keyword]
            ),
            SyntaxFixture(
                language: .powershell,
                source: "$items | Where-Object { $_ -ne $null }",
                expectations: ["Where-Object": .function, "-ne": .operator, "$null": .builtin]
            ),
            SyntaxFixture(
                language: .sql,
                source: "SELECT users.id FROM users WHERE deleted_at IS NOT NULL;",
                expectations: ["SELECT": .keyword, "WHERE": .keyword, "NULL": .keyword]
            ),
            SyntaxFixture(
                language: .java,
                source: "public record User(String name) {}",
                expectations: ["public": .keyword, "record": .keyword, "String": .className]
            ),
            SyntaxFixture(
                language: .kotlin,
                source: "data class User(val name: String?)",
                expectations: ["data": .keyword, "class": .keyword, "String": .className]
            ),
            SyntaxFixture(
                language: .go,
                source: "func mapValue[T any](value T) T { return value }",
                expectations: ["func": .keyword, "any": .builtin, "return": .keyword]
            ),
            SyntaxFixture(
                language: .ruby,
                source: "users.filter_map { |user| user.name unless user.nil? }",
                expectations: ["filter_map": .function, "unless": .keyword, "nil": .keyword]
            ),
            SyntaxFixture(
                language: .markup,
                source: "<button disabled=\"disabled\">Save</button>",
                expectations: ["button": .tag, "disabled": .attribute, "\"disabled\"": .string]
            ),
            SyntaxFixture(
                language: .css,
                source: ".button { color: rgb(255 0 0 / 50%); }",
                expectations: [".button": .selector, "color": .property, "rgb": .function]
            ),
            SyntaxFixture(
                language: .json,
                source: "{\"enabled\": true, \"count\": 3}",
                expectations: ["\"enabled\"": .property, "true": .boolean, "3": .number]
            ),
            SyntaxFixture(
                language: .yaml,
                source: "enabled: true\nitems:\n  - one",
                expectations: ["enabled": .attribute, "true": .boolean]
            ),
            SyntaxFixture(
                language: .markdown,
                source: "## Title\nUse **bold** and `code`.",
                expectations: ["## Title": .title, "**bold**": .bold, "`code`": .code]
            ),
            SyntaxFixture(
                language: .dart,
                source: "Future<String?> load() async => value ?? 'none';",
                expectations: ["Future": .className, "async": .keyword, "??": .operator]
            ),
            SyntaxFixture(
                language: .scala,
                source: "case class User(name: Option[String])",
                expectations: ["case": .keyword, "class": .keyword, "User": .className]
            ),
            SyntaxFixture(
                language: .lua,
                source: "local value = item or \"fallback\"",
                expectations: ["local": .keyword, "or": .keyword, "\"fallback\"": .string]
            ),
            SyntaxFixture(
                language: .graphql,
                source: "query User($id: ID!) { user(id: $id) { name } }",
                expectations: ["query": .keyword, "$id": .variable, "ID": .className]
            )
        ]
        let highlighter = SyntaxHighlighter()

        #expect(fixtures.count == SyntaxLanguage.bundled.count)

        for fixture in fixtures {
            let highlighted = try highlighter.highlight(fixture.source, language: fixture.language)
            #expect(highlighted.source == fixture.source)
            #expect(highlighted.language == fixture.language)
            highlighted.validateRanges()

            for (text, expectedKind) in fixture.expectations {
                #expect(
                    try highlighted.tokenKind(for: text) == expectedKind,
                    "Unexpected token for \(fixture.language.rawValue): \(text)"
                )
            }
        }
    }

    @Test("Malformed and incomplete snippets remain lossless")
    func incompleteSnippets() throws {
        let highlighter = SyntaxHighlighter()
        let fixtures: [(SyntaxLanguage, String)] = [
            (.swift, "let message = \"value: \\(items.map { $0"),
            (.javascript, "const value = { nested: [1, 2,"),
            (.python, "def unfinished(value:\n    return f\"value {value"),
            (.php, "<?php function unfinished($value) {")
        ]

        for (language, source) in fixtures {
            let highlighted = try highlighter.highlight(source, language: language)
            #expect(highlighted.source == source)
            highlighted.validateRanges()
        }
    }

    @Test("Unicode before and inside tokens produces valid Swift ranges")
    func unicodeRanges() throws {
        let source = "let greeting = \"👋🏽 Hello \\(name)\" // café"
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "\"👋🏽 Hello ") == .string)
        #expect(try highlighted.tokenKind(for: "// café") == .comment)
        highlighted.validateRanges()
    }
}
