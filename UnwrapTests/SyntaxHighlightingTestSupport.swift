//
//  SyntaxHighlightingTestSupport.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

struct SyntaxFixture: Sendable {
    let language: SyntaxLanguage
    let source: String
    let expectations: [String: SyntaxTokenKind]
}

extension HighlightedCode {
    func tokenKind(for text: String) throws -> SyntaxTokenKind {
        if let exactToken = tokens.first(where: { token in
            source[token.range] == text
        }) {
            return exactToken.kind
        }

        let textRange = try #require(source.range(of: text), "Missing fixture text: \(text)")
        let token = try #require(
            tokens.first { token in
                token.range.lowerBound <= textRange.lowerBound
                    && token.range.upperBound >= textRange.upperBound
            },
            "No token covers fixture text: \(text)"
        )
        return token.kind
    }

    func validateRanges() {
        var previousUpperBound = source.startIndex

        for token in tokens {
            #expect(token.range.isEmpty == false)
            #expect(token.range.lowerBound >= source.startIndex)
            #expect(token.range.upperBound <= source.endIndex)
            #expect(token.range.lowerBound >= previousUpperBound)
            #expect(token.scopes.isEmpty == false)
            previousUpperBound = token.range.upperBound
        }
    }
}
