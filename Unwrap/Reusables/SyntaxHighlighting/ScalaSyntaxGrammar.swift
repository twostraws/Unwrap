//
//  ScalaSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct ScalaSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .scala,
            keywords: [
                "abstract", "case", "catch", "class", "def", "derives", "do", "else", "end", "enum", "export",
                "extends", "extension", "final", "finally", "for", "forSome", "given", "if", "implicit",
                "import", "inline", "lazy", "match", "new", "null", "object", "opaque", "open", "override",
                "package", "private", "protected", "return", "sealed", "super", "then", "this", "throw", "trait",
                "transparent", "try", "type", "using", "val", "var", "while", "with", "yield"
            ],
            builtins: [
                "Any", "AnyRef", "AnyVal", "Boolean", "Byte", "Char", "Double", "Float", "Int", "Long", "Nothing",
                "Null", "Short", "Unit"
            ],
            classNames: ["Either", "Future", "List", "Map", "Option", "Seq", "Set", "Some", "String"],
            lineCommentMarkers: ["//"],
            blockComments: [.init("/*", "*/", allowsNesting: true)],
            stringDelimiters: [
                .init("\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators,
            classifiesCapitalizedIdentifiersAsClasses: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
