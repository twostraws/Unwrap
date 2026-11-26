//
//  GoSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct GoSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .go,
            keywords: [
                "break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough",
                "for", "func", "go", "goto", "if", "import", "interface", "map", "package", "range",
                "return", "select", "struct", "switch", "type", "var"
            ],
            builtins: [
                "any", "append", "bool", "byte", "cap", "clear", "close", "comparable", "complex",
                "complex128", "complex64", "copy", "delete", "error", "float32", "float64", "imag", "int",
                "int16", "int32", "int64", "int8", "len", "make", "max", "min", "new", "panic", "print",
                "println", "real", "recover", "rune", "string", "uint", "uint16", "uint32", "uint64", "uint8",
                "uintptr"
            ],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("`", escapeCharacter: nil, allowsNewlines: true),
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
