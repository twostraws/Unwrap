//
//  ObjectiveCSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct ObjectiveCSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .objectiveC,
            keywords: CSyntaxGrammar.keywords.union([
                "@autoreleasepool", "@catch", "@class", "@dynamic", "@encode", "@end", "@finally",
                "@implementation", "@interface", "@optional", "@package", "@private", "@property",
                "@protected", "@protocol", "@public", "@required", "@selector", "@synchronized",
                "@synthesize", "@throw", "@try", "instancetype"
            ]),
            builtins: ["id", "nil", "Nil", "SEL", "YES", "NO"],
            classNames: ["NSArray", "NSDictionary", "NSObject", "NSString"],
            lineCommentMarkers: ["//"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("@\"", closing: "\""),
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
