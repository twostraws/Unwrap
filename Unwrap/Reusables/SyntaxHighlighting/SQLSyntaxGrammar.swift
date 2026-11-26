//
//  SQLSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct SQLSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .sql,
            keywords: [
                "add", "all", "alter", "and", "any", "as", "asc", "begin", "between", "by", "case",
                "check", "column", "commit", "constraint", "create", "cross", "database", "default",
                "delete", "desc", "distinct", "drop", "else", "end", "exists", "foreign", "from", "full",
                "group", "having", "in", "index", "inner", "insert", "intersect", "into", "is", "join",
                "key", "left", "like", "limit", "natural", "not", "null", "on", "or", "order", "outer",
                "primary", "references", "returning", "right", "rollback", "select", "set", "table", "then",
                "union", "unique", "update", "using", "values", "view", "when", "where", "with"
            ],
            builtins: [
                "avg", "coalesce", "count", "current_date", "current_time", "current_timestamp", "lower",
                "max", "min", "sum", "upper"
            ],
            lineCommentMarkers: ["--"],
            blockComments: GenericNativeScanner.cStyleBlockComments,
            stringDelimiters: [
                .init("'", escapeCharacter: nil, doublesClosingDelimiter: true),
                .init("\"", escapeCharacter: nil, doublesClosingDelimiter: true),
                .init("`", escapeCharacter: nil)
            ],
            operators: GenericNativeScanner.cStyleOperators,
            isCaseInsensitive: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
