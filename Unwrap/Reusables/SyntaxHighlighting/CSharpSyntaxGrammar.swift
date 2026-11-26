//
//  CSharpSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct CSharpSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .cSharp,
            keywords: [
                "abstract", "as", "async", "await", "base", "break", "case", "catch", "checked",
                "class", "const", "continue", "decimal", "default", "delegate", "do", "else", "enum",
                "event", "explicit", "extern", "finally", "fixed", "for", "foreach", "get",
                "goto", "if", "implicit", "in", "init", "interface", "internal", "is", "lock", "namespace",
                "new", "null", "operator", "out", "override", "params", "partial", "private", "protected",
                "public", "readonly", "record", "ref", "required", "return", "scoped", "sealed", "set",
                "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw",
                "try", "typeof", "unchecked", "unsafe", "using", "virtual", "void", "volatile", "while",
                "var", "yield"
            ],
            builtins: [
                "bool", "byte", "char", "double", "dynamic", "float", "int", "long", "nint", "nuint",
                "object", "sbyte", "short", "uint", "ulong", "ushort"
            ],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("$@\"", closing: "\"", escapeCharacter: nil, allowsNewlines: true, doublesClosingDelimiter: true),
                .init("@$\"", closing: "\"", escapeCharacter: nil, allowsNewlines: true, doublesClosingDelimiter: true),
                .init("\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("@\"", closing: "\"", escapeCharacter: nil, allowsNewlines: true, doublesClosingDelimiter: true),
                .init("$\"", closing: "\""),
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators,
            classifiesCapitalizedIdentifiersAsClasses: true,
            recognizesHashDirectives: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
