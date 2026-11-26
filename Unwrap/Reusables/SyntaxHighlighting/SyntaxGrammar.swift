//
//  SyntaxGrammar.swift
//  Unwrap
//

nonisolated protocol SyntaxGrammar: Sendable {
    func tokens(in source: String) -> [SyntaxToken]
}
