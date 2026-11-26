//
//  SyntaxToken.swift
//  Unwrap
//

nonisolated struct SyntaxToken: Equatable, Sendable {
    let kind: SyntaxTokenKind
    let range: Range<String.Index>
    let scopes: [String]
}
