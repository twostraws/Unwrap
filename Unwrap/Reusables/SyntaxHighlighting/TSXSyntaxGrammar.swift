//
//  TSXSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct TSXSyntaxGrammar: SyntaxGrammar {
    func tokens(in source: String) -> [SyntaxToken] {
        TypeScriptSyntaxGrammar.scanner(
            language: .tsx,
            recognizesMarkupTags: true
        ).tokens(in: source)
    }
}
