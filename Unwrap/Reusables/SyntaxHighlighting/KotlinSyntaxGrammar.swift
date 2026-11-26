//
//  KotlinSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct KotlinSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .kotlin,
            keywords: [
                "actual", "as", "break", "by", "catch", "class", "companion", "const", "constructor",
                "continue", "crossinline", "data", "delegate", "do", "dynamic", "else", "enum", "expect",
                "external", "field", "file", "final", "finally", "for", "fun", "get", "if", "import", "in",
                "infix", "init", "inline", "inner", "interface", "internal", "is", "lateinit", "noinline",
                "null", "object", "open", "operator", "out", "override", "package", "private", "protected",
                "public", "reified", "return", "sealed", "set", "setparam", "super", "suspend", "tailrec",
                "this", "throw", "try", "typealias", "typeof", "val", "var", "vararg", "when", "where", "while"
            ],
            builtins: [
                "Any", "Boolean", "Byte", "Char", "Double", "Float", "Int", "Long", "Nothing", "Short",
                "Unit"
            ],
            classNames: ["Array", "List", "Map", "Result", "Sequence", "Set", "String"],
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
