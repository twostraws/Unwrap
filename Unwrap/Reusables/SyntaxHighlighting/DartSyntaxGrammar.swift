//
//  DartSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct DartSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .dart,
            keywords: [
                "abstract", "as", "assert", "async", "await", "base", "break", "case", "catch", "class",
                "const", "continue", "covariant", "default", "deferred", "do", "dynamic", "else", "enum",
                "export", "extends", "extension", "external", "factory", "final", "finally", "for", "get", "hide",
                "if", "implements", "import", "in", "interface", "late", "library", "mixin", "new", "null", "of",
                "on", "operator", "part", "required", "rethrow", "return", "sealed", "set", "show", "static",
                "super", "switch", "sync", "this", "throw", "try", "typedef", "var", "when", "while", "with",
                "yield"
            ],
            builtins: ["bool", "double", "dynamic", "int", "num", "void"],
            classNames: [
                "DateTime", "Duration", "Error", "Exception", "Future", "Iterable", "List", "Map", "Never",
                "Object", "Record", "Set", "Stream", "String", "Symbol", "Type"
            ],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("r\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("r'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("\"\"\"", allowsNewlines: true),
                .init("'''", allowsNewlines: true),
                .init("r\"", closing: "\"", escapeCharacter: nil),
                .init("r'", closing: "'", escapeCharacter: nil),
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
