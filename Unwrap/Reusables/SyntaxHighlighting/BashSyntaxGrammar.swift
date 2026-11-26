//
//  BashSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct BashSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .bash,
            keywords: [
                "case", "coproc", "do", "done", "elif", "else", "esac", "fi", "for", "function",
                "if", "in", "select", "then", "time", "until", "while"
            ],
            builtins: [
                "alias", "bg", "bind", "break", "builtin", "cd", "command", "continue", "declare",
                "echo", "enable", "eval", "exec", "exit", "export", "false", "fc", "fg", "getopts",
                "hash", "help", "history", "jobs", "kill", "let", "local", "logout", "mapfile",
                "printf", "pwd", "read", "readonly", "return", "set", "shift", "shopt", "source",
                "suspend", "test", "times", "trap", "true", "type", "typeset", "ulimit", "umask",
                "unalias", "unset", "wait"
            ],
            booleans: [],
            lineCommentMarkers: ["#"],
            stringDelimiters: [
                .init("\""),
                .init("'", escapeCharacter: nil),
                .init("`", allowsNewlines: true)
            ],
            operators: GenericNativeScanner.cStyleOperators,
            variablePrefixes: ["$"]
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
