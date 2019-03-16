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
