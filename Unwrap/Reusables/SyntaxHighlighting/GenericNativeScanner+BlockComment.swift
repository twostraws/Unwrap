//
//  GenericNativeScanner+BlockComment.swift
//  Unwrap
//

extension GenericNativeScanner {
    nonisolated struct BlockComment: Sendable {
        let opening: String
        let closing: String
        let allowsNesting: Bool

        init(_ opening: String, _ closing: String, allowsNesting: Bool = false) {
            self.opening = opening
            self.closing = closing
            self.allowsNesting = allowsNesting
        }
    }
}
