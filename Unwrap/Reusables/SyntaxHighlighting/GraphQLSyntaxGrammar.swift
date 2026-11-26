//
//  GraphQLSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct GraphQLSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .graphql,
            keywords: [
                "directive", "enum", "extend", "fragment", "implements", "input", "interface", "mutation", "null",
                "on", "query", "repeatable", "scalar", "schema", "subscription", "type", "union"
            ],
            classNames: ["Boolean", "Float", "ID", "Int", "String"],
            lineCommentMarkers: ["#"],
            stringDelimiters: [
                .init("\"\"\"", allowsNewlines: true),
                .init("\"")
            ],
            operators: ["...", "!", "$", "(", ")", ":", "=", "@", "[", "]", "{", "}", "|", "&"],
            variablePrefixes: ["$"],
            classifiesCapitalizedIdentifiersAsClasses: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
