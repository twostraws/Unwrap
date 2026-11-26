//
//  CppSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct CppSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .cpp,
            keywords: CSyntaxGrammar.keywords.union([
                "alignas", "alignof", "and", "and_eq", "asm", "bitand", "bitor", "bool", "catch",
                "char16_t", "char32_t", "char8_t", "class", "compl", "concept", "consteval",
                "constexpr", "constinit", "const_cast", "co_await", "co_return", "co_yield", "decltype",
                "delete", "dynamic_cast", "explicit", "export", "false", "friend", "inline", "mutable",
                "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq",
                "private", "protected", "public", "reinterpret_cast", "requires", "static_assert",
                "static_cast", "template", "this", "thread_local", "throw", "true", "try", "typeid",
                "typename", "using", "virtual", "wchar_t", "xor", "xor_eq"
            ]),
            builtins: ["size_t", "std", "string", "vector"],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: GenericNativeScanner.cStyleStrings,
            operators: GenericNativeScanner.cStyleOperators,
            classifiesCapitalizedIdentifiersAsClasses: true,
            recognizesHashDirectives: true,
            recognizesCppRawStrings: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
