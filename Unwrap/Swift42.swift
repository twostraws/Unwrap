//
//  Swift42.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//
//  Code to tide us over until Swift 4.2 ships, at which
//  point this file will mostly go away.
//

import GameplayKit
import UIKit

/// A dummy protocol to remind me that we can remove the allCases hand-coded enum when moving to Swift 4.2.
protocol CaseIterable { }

extension Float {
    /// Generates a random number of several different sizes.
    static func scaledRandom() -> Float {
        switch arc4random_uniform(3) {
        case 0:
            return GKRandomSource.sharedRandom().nextUniform()

        case 1:
            return GKRandomSource.sharedRandom().nextUniform() * Float(GKRandomSource.sharedRandom().nextInt(upperBound: 10))

        default:
            return GKRandomSource.sharedRandom().nextUniform() * Float(GKRandomSource.sharedRandom().nextInt(upperBound: 100))
        }
    }
}

extension Int {
    /// Generates a random integer in a range.
    static func random(in range: CountableRange<Int>) -> Int {
        return numericCast(arc4random_uniform(numericCast(range.count)))
            + range.lowerBound
    }

    /// Generates a random integer in a range.
    static func random(in range: CountableClosedRange<Int>) -> Int {
        return numericCast(arc4random_uniform(numericCast(range.count)))
            + range.lowerBound
    }
}

extension Array {
    /// Extracts a random element from an array, or nil if the array is empty.
    func randomElement() -> Element? {
        if count == 0 { return nil }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }

    /// Shuffles an array in place.
    mutating func shuffle() {
        self = shuffled()
    }

    /// Shuffles an array and returns the shuffled result.
    func shuffled() -> [Element] {
        // swiftlint:disable:next force_cast
        return (self as NSArray).shuffled() as! [Element]
    }
}

extension Bool {
    /// Returns either true or false randomly.
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }

    /// Flips a boolean from true to false, and from false to true.
    mutating func toggle() {
        self = !self
    }
}
