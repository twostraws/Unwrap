//
//  Skippable.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Implemented by coordinators that allow users to skip sections of the current activity.
protocol Skippable {
    /// Whether or not the user can have multiple attempts at questions
    var retriesAllowed: Bool { get }

    func skipReviewing()
    func skipPracticing()
}

// provide default implementations of both so they must be overridden as needed in each coordinator
extension Skippable {
    func skipReviewing() {
        fatalError("skipReviewing() was called but is not implemented here.")
    }

    func skipPracticing() {
        fatalError("skipPracticing() was called but is not implemented here.")
    }
}
