//
//  YAMLSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct YAMLSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .yaml,
            keywords: ["null", "~"],
            booleans: ["false", "no", "off", "on", "true", "yes"],
            lineCommentMarkers: ["#"],
            stringDelimiters: [
                .init("\""),
                .init("'", escapeCharacter: nil, doublesClosingDelimiter: true)
            ],
            operators: ["---", "...", "-", "?", ":", ",", "[", "]", "{", "}", "&", "*", "!", "|", ">"],
            additionalIdentifierBodyCharacters: ["-"],
            isCaseInsensitive: true,
            identifiersBeforeColon: .attribute
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
