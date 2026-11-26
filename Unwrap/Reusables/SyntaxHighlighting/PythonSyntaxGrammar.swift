//
//  PythonSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct PythonSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .python,
            keywords: [
                "None", "and", "as", "assert", "async", "await", "break", "case", "class",
                "continue", "def", "del", "elif", "else", "except", "finally", "for", "from",
                "global", "if", "import", "in", "is", "lambda", "match", "nonlocal", "not",
                "or", "pass", "raise", "return", "try", "while", "with", "yield"
            ],
            builtins: [
                "abs", "all", "any", "bool", "bytes", "callable", "dict", "enumerate", "filter",
                "float", "frozenset", "getattr", "hasattr", "hash", "help", "hex", "id", "input",
                "int", "isinstance", "issubclass", "iter", "len", "list", "map", "max", "min",
                "next", "object", "open", "ord", "print", "property", "range", "repr", "reversed",
                "round", "set", "slice", "sorted", "str", "sum", "super", "tuple", "type", "zip"
            ],
            booleans: ["False", "True"],
            lineCommentMarkers: ["#"],
            stringDelimiters: [
                .init("fr\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("fr'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("rf\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("rf'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("f\"\"\"", closing: "\"\"\"", allowsNewlines: true),
                .init("f'''", closing: "'''", allowsNewlines: true),
                .init("br\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("br'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("rb\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("rb'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("r\"\"\"", closing: "\"\"\"", escapeCharacter: nil, allowsNewlines: true),
                .init("r'''", closing: "'''", escapeCharacter: nil, allowsNewlines: true),
                .init("b\"\"\"", closing: "\"\"\"", allowsNewlines: true),
                .init("b'''", closing: "'''", allowsNewlines: true),
                .init("u\"\"\"", closing: "\"\"\"", allowsNewlines: true),
                .init("u'''", closing: "'''", allowsNewlines: true),
                .init("\"\"\"", allowsNewlines: true),
                .init("'''", allowsNewlines: true),
                .init("fr\"", closing: "\"", escapeCharacter: nil),
                .init("fr'", closing: "'", escapeCharacter: nil),
                .init("rf\"", closing: "\"", escapeCharacter: nil),
                .init("rf'", closing: "'", escapeCharacter: nil),
                .init("f\"", closing: "\""),
                .init("f'", closing: "'"),
                .init("br\"", closing: "\"", escapeCharacter: nil),
                .init("br'", closing: "'", escapeCharacter: nil),
                .init("rb\"", closing: "\"", escapeCharacter: nil),
                .init("rb'", closing: "'", escapeCharacter: nil),
                .init("r\"", closing: "\"", escapeCharacter: nil),
                .init("r'", closing: "'", escapeCharacter: nil),
                .init("b\"", closing: "\""),
                .init("b'", closing: "'"),
                .init("u\"", closing: "\""),
                .init("u'", closing: "'"),
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
