//
//  ReviewAnswer.swift
//  Unwrap
//

import Foundation

struct ReviewAnswer: Codable, Hashable {
    let text: String
    let reason: String

    private enum CodingKeys: String, CodingKey {
        case text = "answer"
        case reason
    }
}
