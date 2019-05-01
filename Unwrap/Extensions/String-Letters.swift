//
//  String-Letters.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension String {
    /// Returns true if this string starts with a vowel.
    var startsWithVowel: Bool {
        return ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"].contains(first)
    }

    /// This attempts to adjust the way iOS performs line breaking, by replacing two important character pairs ("\(" for string interpolation, and "->" for function return types) with those same characters separated by U+2060. This is the "word joiner" character, and it says that word separation should not happen. This is only "should" – it's advisory! – but all we can do is try.
    func fixingLineWrapping() -> String {
        var reflowed = self.replacingOccurrences(of: "\\(", with: "\\\u{2060}(")
        reflowed = reflowed.replacingOccurrences(of: "->", with: "-\u{2060}>")
        return reflowed
    }
}
