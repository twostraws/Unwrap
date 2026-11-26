//
//  JSXSyntaxGrammar.swift
//  Unwrap
//

nonisolated struct JSXSyntaxGrammar: SyntaxGrammar {
    func tokens(in source: String) -> [SyntaxToken] {
        JavaScriptSyntaxGrammar.scanner(
            language: .jsx,
            recognizesMarkupTags: true
        ).tokens(in: source)
    }
}
