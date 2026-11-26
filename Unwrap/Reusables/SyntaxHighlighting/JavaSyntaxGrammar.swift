//
//  JavaSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct JavaSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .java,
            keywords: [
                "abstract", "assert", "break", "case", "catch", "class", "const", "continue", "default",
                "do", "else", "enum", "exports", "extends", "final", "finally", "for", "goto", "if",
                "implements", "import", "instanceof", "interface", "module", "native", "new", "non-sealed",
                "null", "open", "opens", "package", "permits", "private", "protected", "provides", "public",
                "record", "requires", "return", "sealed", "static", "strictfp", "super", "switch",
                "synchronized", "this", "throw", "throws", "to", "transient", "transitive", "try", "uses",
                "volatile", "while", "with", "yield"
            ],
            builtins: ["boolean", "byte", "char", "double", "float", "int", "long", "short", "void"],
            classNames: [
                "Boolean", "Byte", "Character", "Class", "Double", "Exception", "Float", "Integer",
                "Iterable", "List", "Long", "Map", "Object", "Optional", "RuntimeException", "Set", "Short",
                "String", "StringBuilder", "System", "Throwable"
            ],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("\"\"\"", allowsNewlines: true),
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
