//
//  CSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct CSyntaxGrammar: SyntaxGrammar {
    static let keywords: Set<String> = [
        "_Alignas", "_Alignof", "_Atomic", "_Bool", "_Complex", "_Generic", "_Imaginary",
        "_Noreturn", "_Static_assert", "_Thread_local", "auto", "break", "case", "char", "const",
        "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto",
        "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed", "sizeof",
        "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"
    ]

    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .c,
            keywords: keywords,
            builtins: ["NULL", "size_t", "ptrdiff_t", "FILE"],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: GenericNativeScanner.cStyleStrings,
            operators: GenericNativeScanner.cStyleOperators,
            recognizesHashDirectives: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
