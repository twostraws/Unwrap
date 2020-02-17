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

    /// Calculates the first line where two strings differ, or returns -1.
    func lineDiff(from other: String) -> Int {
        var counter = 0

        for (ourLine, theirLine) in zip(self.lines, other.lines) {
            if ourLine != theirLine {
                return counter
            }

            counter += 1
        }

        return -1
    }
}
