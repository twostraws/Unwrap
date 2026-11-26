//
//  PHPSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct PHPSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .php,
            keywords: [
                "abstract", "and", "array", "as", "break", "callable", "case", "catch", "class",
                "clone", "const", "continue", "declare", "default", "die", "do", "echo", "else",
                "elseif", "empty", "enddeclare", "endfor", "endforeach", "endif", "endswitch",
                "endwhile", "enum", "eval", "exit", "extends", "final", "finally", "fn", "for",
                "foreach", "from", "function", "global", "goto", "if", "implements", "include",
                "include_once", "instanceof", "insteadof", "interface", "isset", "list", "match",
                "namespace", "new", "null", "or", "print", "private", "protected", "public",
                "readonly", "require", "require_once", "return", "static", "switch", "throw", "trait",
                "try", "unset", "use", "var", "while", "xor", "yield"
            ],
            builtins: ["parent", "self"],
            lineCommentMarkers: ["//", "#"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("`", allowsNewlines: true),
                .init("\""),
                .init("'")
            ],
            operators: GenericNativeScanner.cStyleOperators,
            variablePrefixes: ["$"],
            isCaseInsensitive: true,
            classifiesCapitalizedIdentifiersAsClasses: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
