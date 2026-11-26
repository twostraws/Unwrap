//
//  SyntaxHighlightingError.swift
//  Unwrap
//

nonisolated enum SyntaxHighlightingError: Error, Equatable, Sendable {
    case unsupportedLanguage(String)
}
