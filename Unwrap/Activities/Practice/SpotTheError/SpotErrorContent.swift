//
//  SpotErrorContent.swift
//  Unwrap
//

import Foundation

struct SpotErrorContent: Decodable, Equatable {
    struct Replacement: Decodable, Equatable {
        let name: String
        let values: [String]
    }

    let file: String
    let replacements: [Replacement]
    let inputMinimum: Int
    let inputMaximum: Int
}
