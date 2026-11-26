//
//  PowerShellSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct PowerShellSyntaxGrammar: SyntaxGrammar {
    private static let scanner = GenericNativeScanner(
        configuration: .init(
            language: .powershell,
            keywords: [
                "begin", "break", "catch", "class", "continue", "data", "define", "do", "dynamicparam",
                "else", "elseif", "end", "enum", "exit", "filter", "finally", "for", "foreach", "from",
                "function", "if", "in", "param", "process", "return", "switch", "throw", "trap", "try",
                "until", "using", "var", "while", "workflow"
            ],
            functions: [
                "Add-Content", "ForEach-Object", "Get-ChildItem", "Get-Command", "Get-Content",
                "Get-Item", "Get-Member", "Measure-Object", "New-Item", "Out-Host", "Select-Object",
                "Set-Content", "Sort-Object", "Tee-Object", "Where-Object", "Write-Error",
                "Write-Host", "Write-Output", "Write-Warning"
            ],
            booleans: [],
            builtinVariables: ["$_", "$args", "$false", "$null", "$this", "$true"],
            lineCommentMarkers: ["#"],
            blockComments: [.init("<#", "#>")],
            stringDelimiters: [
                .init("@\"", closing: "\"@", allowsNewlines: true),
                .init("@'", closing: "'@", escapeCharacter: nil, allowsNewlines: true),
                .init("\"", escapeCharacter: "`"),
                .init("'", escapeCharacter: nil, doublesClosingDelimiter: true)
            ],
            operators: [
                "-contains", "-notcontains", "-notmatch", "-replace", "-isnot", "-match", "-like",
                "-notlike", "-eq", "-ne", "-gt", "-ge", "-lt", "-le", "-and", "-or", "-not",
                "-xor", "-in", "-notin", "-is", "-as"
            ] + GenericNativeScanner.cStyleOperators,
            variablePrefixes: ["$"],
            additionalIdentifierBodyCharacters: ["-"],
            isCaseInsensitive: true,
            classifiesCallsBeforeBracesAsFunctions: true
        )
    )

    func tokens(in source: String) -> [SyntaxToken] {
        Self.scanner.tokens(in: source)
    }
}
