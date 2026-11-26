//
//  RubySyntaxGrammar.swift
//  Unwrap
//

nonisolated struct RubySyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .ruby,
            keywords: [
                "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined",
                "do", "else", "elsif", "end", "ensure", "for", "if", "in", "module", "next", "nil", "not",
                "or", "redo", "rescue", "retry", "return", "self", "super", "then", "undef", "unless",
                "until", "when", "while", "yield"
            ],
            builtins: [
                "Array", "BasicObject", "Class", "Dir", "Encoding", "Enumerable", "Exception", "File", "Float",
                "Hash", "Integer", "Kernel", "Math", "Module", "Object", "Proc", "Range", "Regexp", "String",
                "Struct", "Symbol", "Time"
            ],
            lineCommentMarkers: ["#"],
            blockComments: [.init("=begin", "=end")],
            stringDelimiters: [
                .init("\""),
                .init("'", escapeCharacter: "\\"),
                .init("`", allowsNewlines: true)
            ],
            operators: GenericNativeScanner.cStyleOperators + ["<=>", "=~", "!~"],
            variablePrefixes: ["@@", "@", "$"],
            classifiesCapitalizedIdentifiersAsClasses: true,
            classifiesCallsBeforeBracesAsFunctions: true,
            recognizesSlashRegexLiterals: true,
            regexPrefixKeywords: [
                "and", "case", "do", "else", "elsif", "if", "in", "not", "or", "return",
                "then", "unless", "until", "when", "while", "yield"
            ]
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
