//
//  Numeric-Formatted.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A collection of helpful methods for formatting numbers and dates as strings.
extension Int {
    /// Returns an integer formatted with thousands separators.
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    /// Returns a number formatted as words, e.g. "ten".
    var spelledOut: String {
        // If this is any sort of English language then convert the integer to words, otherwise just use the integer. This avoids a chunk of English text appearing with a different language number appearing in the middle.
        if Locale.current.languageCode == "en" {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            return formatter.string(from: NSNumber(value: self)) ?? ""
        } else {
            return String(self)
        }
    }
}

extension Double {
    /// Returns a double formatted with thousands separators.
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension Date {
    /// Returns a date formatted in a fixed, reliable way.
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
}
