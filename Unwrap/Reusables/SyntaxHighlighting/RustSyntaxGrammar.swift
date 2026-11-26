//
//  RustSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct RustSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .rust,
            keywords: [
                "as", "async", "await", "break", "const", "continue", "crate", "dyn", "else", "enum",
                "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod",
                "move", "mut", "pub", "ref", "return", "self", "Self", "static", "struct", "super",
                "trait", "true", "type", "union", "unsafe", "use", "where", "while", "yield"
            ],
            builtins: [
                "bool", "char", "f32", "f64", "i8", "i16", "i32", "i64", "i128", "isize", "str",
                "u8", "u16", "u32", "u64", "u128", "usize", "Option", "Result", "String", "Vec"
            ],
            lineCommentMarkers: ["//"],
            blockComments: [.init("/*", "*/", allowsNesting: true)],
            stringDelimiters: [.init("b\"", closing: "\""), .init("\"")],
            operators: GenericNativeScanner.cStyleOperators,
            classifiesCapitalizedIdentifiersAsClasses: true,
            recognizesHashDirectives: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
