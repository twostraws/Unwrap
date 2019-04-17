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
}
