//
//  GenericNativeScanner+StringDelimiter.swift
//  Unwrap
//

extension GenericNativeScanner {
    nonisolated struct StringDelimiter: Sendable {
        let opening: String
        let closing: String
        let escapeCharacter: Character?
        let allowsNewlines: Bool
        let doublesClosingDelimiter: Bool

        init(
            _ opening: String,
            closing: String? = nil,
            escapeCharacter: Character? = "\\",
            allowsNewlines: Bool = false,
            doublesClosingDelimiter: Bool = false
        ) {
            self.opening = opening
            self.closing = closing ?? opening
            self.escapeCharacter = escapeCharacter
            self.allowsNewlines = allowsNewlines
            self.doublesClosingDelimiter = doublesClosingDelimiter
        }
    }
}
