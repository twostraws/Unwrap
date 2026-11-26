//
//  ReviewContent.swift
//  Unwrap
//

import Foundation

struct ReviewContent: Codable, Equatable {
    let title: String
    let postscript: String
    let kind: ReviewKind
    let question: String
    let hint: String
    let correct: [ReviewAnswer]
    let wrong: [ReviewAnswer]
    let syntaxHighlighting: Bool

    private enum CodingKeys: String, CodingKey {
        case title
        case postscript
        case kind = "reviewType"
        case question
        case hint
        case correct
        case wrong
        case syntaxHighlighting
    }
}
