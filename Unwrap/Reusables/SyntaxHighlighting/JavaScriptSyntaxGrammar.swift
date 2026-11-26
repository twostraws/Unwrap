//
//  JavaScriptSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct JavaScriptSyntaxGrammar: SyntaxGrammar {
    static func scanner(
        language: SyntaxLanguage = .javascript,
        recognizesMarkupTags: Bool = false
    ) -> GenericNativeScanner {
        GenericNativeScanner(
            configuration: .init(
                language: language,
                keywords: [
                    "as", "async", "await", "break", "case", "catch", "class", "const",
                    "continue", "debugger", "default", "delete", "do", "else", "export",
                    "extends", "finally", "for", "from", "function", "get", "if", "import",
                    "in", "instanceof", "let", "new", "null", "of", "return", "set", "static",
                    "super", "switch", "this", "throw", "try", "typeof", "var", "void", "while",
                    "with", "yield"
                ],
                builtins: [
                    "Array", "BigInt", "Boolean", "console", "Date", "Error", "Infinity", "JSON",
                    "Map", "Math", "NaN", "Number", "Object", "Promise", "Proxy", "Reflect",
                    "RegExp", "Set", "String", "Symbol", "undefined", "WeakMap", "WeakSet"
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
