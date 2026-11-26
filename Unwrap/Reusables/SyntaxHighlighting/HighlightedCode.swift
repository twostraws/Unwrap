//
//  HighlightedCode.swift
//  Unwrap
//

nonisolated struct HighlightedCode: Equatable, Sendable {
    let source: String
    let language: SyntaxLanguage
    let tokens: [SyntaxToken]
}
