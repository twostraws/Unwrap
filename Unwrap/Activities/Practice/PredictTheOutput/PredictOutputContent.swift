//
//  PredictOutputContent.swift
//  Unwrap
//

import Foundation

struct PredictOutputContent: Decodable, Equatable {
    struct Answer: Decodable, Equatable {
        let conditions: [Condition]?
        let text: String
    }

    struct Condition: Decodable, Equatable {
        let left: String
        let check: String
        let right: String
    }

    let code: String
    let answers: [Answer]
}
