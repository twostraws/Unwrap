//
//  IntNames.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import GameplayKit

extension Int: TypeGenerating {
    static func randomName() -> (name: String, nameNatural: String) {
        let names = ["age", "birds", "books", "bottles", "cars", "customers", "days", "employees", "goals", "high score", "hours", "minutes", "months", "number of users", "people", "points", "sales", "score", "seconds", "sides", "teams", "users", "weeks"]
        let chosen = names[GKRandomSource.sharedRandom().nextInt(upperBound: names.count)]
        return (chosen.formatAsVariable(), chosen)
    }

    static func makeInstance() -> String {
        let storage = letOrVar()
        let choice = randomName()
        let name = choice.name
        let type: String

        if includeType() {
            type = ": Int"
        } else {
            type = ""
        }

        let selectedValue = Int.random(in: 1 ... 9)
        let value = "\(selectedValue)"

        return "\(storage) \(name)\(type) = \(value)"
    }
}
