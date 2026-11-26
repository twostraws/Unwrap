//
//  StringHelpers.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension String {
    /// An array of strings, each representing a line from an original string.
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}
