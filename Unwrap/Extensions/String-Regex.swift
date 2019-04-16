//
//  RegexHelpers.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension String {
    /// Replaces only one regex match with a replacement string. Used when generating errors, because we want to do things like remove only one quote mark.
    func replacingOne(of search: String, with replacement: String) -> String {
        let regex = NSRegularExpression(search)
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)).shuffled()

        if let match = matches.first {
            let range = match.range(at: 1)

            if let swiftRange = Range(range, in: self) {
                let textMatch = self[swiftRange]
                return self.replacingOccurrences(of: textMatch, with: replacement, options: [], range: swiftRange)
            }
        }

        return self
    }
}
