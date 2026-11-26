//
//  FreeCodingContent.swift
//  Unwrap
//

import Foundation

struct FreeCodingContent: Decodable, Equatable {
    let question: String
    let hint: String
    let startingCode: String
    let answers: [String]
}
