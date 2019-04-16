//
//  LetOrVar.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

protocol TypeGenerating {
    static func makeInstance() -> String
}

extension TypeGenerating {
    static func letOrVar() -> String {
        if Bool.random() {
            return "var"
        } else {
            return "let"
        }
    }

    static func includeType() -> Bool {
        return Bool.random()
    }
}
