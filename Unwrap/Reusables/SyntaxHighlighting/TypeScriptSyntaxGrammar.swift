//
//  TypeScriptSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct TypeScriptSyntaxGrammar: SyntaxGrammar {
    static func scanner(
        language: SyntaxLanguage = .typescript,
        recognizesMarkupTags: Bool = false
    ) -> GenericNativeScanner {
        GenericNativeScanner(
            configuration: .init(
                language: language,
                keywords: [
                    "abstract", "as", "asserts", "async", "await", "break", "case", "catch",
                    "class", "const", "constructor", "continue", "declare", "default", "delete",
                    "do", "else", "enum", "export", "extends", "finally", "for", "from", "function",
                    "get", "if", "implements", "import", "in", "infer", "instanceof", "interface",
                    "is", "keyof", "let", "module", "namespace", "new", "null", "of", "private",
                    "protected", "public", "readonly", "return", "satisfies", "set", "static", "super",
                    "switch", "this", "throw", "try", "type", "typeof", "var", "void", "while", "with",
                    "yield"
                ],
                builtins: [
                    "any", "bigint", "boolean", "never", "number", "object", "string", "symbol",
                    "undefined", "unknown", "void", "Array", "Date", "Error", "Map", "Promise",
                    "ReadonlyArray", "Record", "RegExp", "Set"
                ],
                lineCommentMarkers: ["//"],
                blockComments: GenericNativeScanner.cStyleBlockComments,
                stringDelimiters: [
                    .init("`", escapeCharacter: "\\", allowsNewlines: true),
                    .init("\""),
                    .init("'")
                ],
                operators: GenericNativeScanner.cStyleOperators,
                classifiesCapitalizedIdentifiersAsClasses: true,
                recognizesMarkupTags: recognizesMarkupTags,
                recognizesSlashRegexLiterals: true,
                regexPrefixKeywords: [
                    "await", "case", "delete", "do", "else", "in", "instanceof", "of",
                    "return", "throw", "typeof", "void", "yield"
                ]
            )
        )
    }

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner().tokens(in: source)
    }
}
