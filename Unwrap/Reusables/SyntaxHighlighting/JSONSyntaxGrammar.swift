//
//  JSONSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct JSONSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .json,
            keywords: ["null"],
            stringDelimiters: [.init("\"")],
            operators: ["{", "}", "[", "]", ":", ",", "-"],
            stringKeysAreProperties: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
