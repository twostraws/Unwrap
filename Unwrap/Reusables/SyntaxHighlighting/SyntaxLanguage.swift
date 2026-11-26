//
//  SyntaxLanguage.swift
//  Unwrap
//

import Foundation

nonisolated struct SyntaxLanguage: RawRepresentable, Hashable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = Self.normalizedIdentifier(rawValue)
    }

    static let bash = SyntaxLanguage(rawValue: "bash")
    static let c = SyntaxLanguage(rawValue: "c")
    static let cpp = SyntaxLanguage(rawValue: "cpp")
    static let cSharp = SyntaxLanguage(rawValue: "csharp")
    static let css = SyntaxLanguage(rawValue: "css")
    static let dart = SyntaxLanguage(rawValue: "dart")
    static let go = SyntaxLanguage(rawValue: "go")
    static let graphql = SyntaxLanguage(rawValue: "graphql")
    static let java = SyntaxLanguage(rawValue: "java")
    static let javascript = SyntaxLanguage(rawValue: "javascript")
    static let json = SyntaxLanguage(rawValue: "json")
    static let jsx = SyntaxLanguage(rawValue: "jsx")
    static let kotlin = SyntaxLanguage(rawValue: "kotlin")
    static let lua = SyntaxLanguage(rawValue: "lua")
    static let markdown = SyntaxLanguage(rawValue: "markdown")
    static let markup = SyntaxLanguage(rawValue: "markup")
    static let objectiveC = SyntaxLanguage(rawValue: "objectivec")
    static let php = SyntaxLanguage(rawValue: "php")
    static let powershell = SyntaxLanguage(rawValue: "powershell")
    static let python = SyntaxLanguage(rawValue: "python")
    static let ruby = SyntaxLanguage(rawValue: "ruby")
    static let rust = SyntaxLanguage(rawValue: "rust")
    static let scala = SyntaxLanguage(rawValue: "scala")
    static let sql = SyntaxLanguage(rawValue: "sql")
    static let swift = SyntaxLanguage(rawValue: "swift")
    static let tsx = SyntaxLanguage(rawValue: "tsx")
    static let typescript = SyntaxLanguage(rawValue: "typescript")
    static let yaml = SyntaxLanguage(rawValue: "yaml")

    static let bundled: [SyntaxLanguage] = [
        .bash, .c, .cpp, .cSharp, .css, .dart, .go, .graphql, .java,
        .javascript, .json, .jsx, .kotlin, .lua, .markdown, .markup,
        .objectiveC, .php, .powershell, .python, .ruby, .rust, .scala,
        .sql, .swift, .tsx, .typescript, .yaml
    ]

    static func resolve(_ identifier: String) -> SyntaxLanguage? {
        let normalized = normalizedIdentifier(identifier)

        if let alias = aliases[normalized] {
            return alias
        }

        return bundled.first { $0.rawValue == normalized }
    }

    static func normalizedIdentifier(_ identifier: String) -> String {
        identifier
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static let aliases: [String: SyntaxLanguage] = [
        "c#": .cSharp,
        "c++": .cpp,
        "cs": .cSharp,
        "gql": .graphql,
        "h": .c,
        "h++": .cpp,
        "htm": .markup,
        "html": .markup,
        "js": .javascript,
        "m": .objectiveC,
        "md": .markdown,
        "mm": .objectiveC,
        "objc": .objectiveC,
        "objective-c": .objectiveC,
        "ps1": .powershell,
        "pwsh": .powershell,
        "py": .python,
        "rb": .ruby,
        "sh": .bash,
        "shell": .bash,
        "ts": .typescript,
        "xml": .markup,
        "yml": .yaml,
        "zsh": .bash
    ]
}
