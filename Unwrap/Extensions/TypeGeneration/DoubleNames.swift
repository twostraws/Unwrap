//
//  DoubleNames.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import GameplayKit

extension Double: TypeGenerating {
    static func randomName() -> String {
        let names = ["days", "depth", "distance", "height", "hours", "minutes", "months", "multiplier", "score", "seconds", "temperature", "weeks", "weight", "width"]
        let chosen = names[GKRandomSource.sharedRandom().nextInt(upperBound: names.count)]
        return chosen
    }

    static func makeInstance() -> String {
        let storage = letOrVar()
        let name = randomName()
        let type: String

        if includeType() {
            type = ": Double"
        } else {
            type = ""
        }

        var value = String(format: "%.4g", Float.scaledRandom())

        // if we aren't declaring a type make sure we always have some numbers
        // after the decimal point otherwise this is an integer
        if type.isEmpty {
            if !value.contains(".") {
                value = value.appending(".0")
            }
        }

        return "\(storage) \(name)\(type) = \(value)"
    }
}
