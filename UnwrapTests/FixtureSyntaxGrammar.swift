//
//  FixtureSyntaxGrammar.swift
//  UnwrapTests
//

@testable import Unwrap

struct FixtureSyntaxGrammar: SyntaxGrammar {
    func tokens(in source: String) -> [SyntaxToken] {
        guard source.isEmpty == false else { return [] }
        return [
            SyntaxToken(
                kind: .code,
                range: source.startIndex..<source.endIndex,
                scopes: ["source.fixture", "code"]
            )
        ]
    }
}
