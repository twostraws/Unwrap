//
//  FloatNames.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import GameplayKit

extension Float: TypeGenerating {
    static func randomName() -> String {
        return Double.randomName()
    }

    static func makeInstance() -> String {
        let storage = letOrVar()
        let name = randomName()
        let type = ": Float" // always include the type, otherwise this will be a Double

        let value = String(format: "%.4g", Float.scaledRandom())
        return "\(storage) \(name)\(type) = \(value)"
    }
}
