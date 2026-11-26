//
//  CodeLineWrapping.swift
//  Unwrap
//

nonisolated enum CodeLineWrapping: Equatable, Sendable {
    case disabled
    case enabled

    var allowsWrapping: Bool {
        self == .enabled
    }

    /// Code is never hyphenated because inserted hyphens can be mistaken for source characters.
    var allowsHyphenation: Bool {
        false
    }
}
