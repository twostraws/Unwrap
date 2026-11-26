//
//  MarkupSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct MarkupSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .markup,
            keywords: ["DOCTYPE"],
            booleans: ["false", "true"],
            lineCommentMarkers: [],
            blockComments: [.init("<!--", "-->")],
            stringDelimiters: [
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators,
            additionalIdentifierBodyCharacters: ["-", ":"],
            recognizesMarkupTags: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
