//
//  CSSSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct CSSSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .css,
            keywords: [
                "and", "important", "not", "only", "or"
            ],
            builtins: [
                "inherit", "initial", "none", "revert", "revert-layer", "transparent", "unset"
            ],
            lineCommentMarkers: [],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators,
            additionalIdentifierStartCharacters: ["-"],
            additionalIdentifierBodyCharacters: ["-"],
            recognizesCSSSelectors: true,
            identifiersBeforeColon: .property,
            colonClassificationRequiresBraces: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
