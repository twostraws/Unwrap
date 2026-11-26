//
//  NSRegularExpression-HardCoded.swift
//  Unwrap
//

import Foundation

extension NSRegularExpression {
    /// Creates a regular expression for a developer-authored pattern.
    convenience init(_ pattern: String, options: Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid developer-authored regular expression: \(pattern)")
        }
    }
}
