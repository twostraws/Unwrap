//
//  String-Attributed.swift
//  Unwrap
//
//  Created by Paul Hudson on 16/04/2019.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension Float {
    /// Generates a random number of several different sizes.
    static func scaledRandom() -> Float {
        switch Int.random(in: 0...2) {
        case 0:
            return Float.random(in: 0...1)

        case 1:
            return Float.random(in: 0...1) * Float(Int.random(in: 1...10))

        default:
            return Float.random(in: 0...1) * Float(Int.random(in: 1...100))
        }
    }
}
