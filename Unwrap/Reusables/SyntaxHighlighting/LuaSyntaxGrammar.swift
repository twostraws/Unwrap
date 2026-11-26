//
//  LuaSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct LuaSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .lua,
            keywords: [
                "and", "break", "do", "else", "elseif", "end", "for", "function", "goto", "if", "in", "local",
                "nil", "not", "or", "repeat", "return", "then", "until", "while"
            ],
            builtins: [
                "assert", "collectgarbage", "coroutine", "debug", "dofile", "error", "getmetatable", "io", "ipairs",
                "load", "math", "next", "os", "package", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen",
                "rawset", "require", "select", "setmetatable", "string", "table", "tonumber", "tostring", "type", "utf8",
                "warn", "xpcall"
            ],
            lineCommentMarkers: ["--"],
            blockComments: [.init("--[[", "]]"), .init("--[=[", "]=]")],
            stringDelimiters: [
                .init("[[", closing: "]]", escapeCharacter: nil, allowsNewlines: true),
                .init("[=[", closing: "]=]", escapeCharacter: nil, allowsNewlines: true),
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators + ["//", "..", "#"]
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
