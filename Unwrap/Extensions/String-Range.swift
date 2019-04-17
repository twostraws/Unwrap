//
//  String-Range.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension String {
    /// Converts an NSRange into a Swift String range, then sends back the substring of ourself at that range.
    func substring(at range: NSRange) -> String {
        guard let swiftRange = Range(range, in: self) else {
            fatalError("Attempting to read invalid range in string: \(range).")
        }

        return String(self[swiftRange])
    }
}
