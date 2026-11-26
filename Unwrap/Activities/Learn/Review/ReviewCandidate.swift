//
//  ReviewCandidate.swift
//  Unwrap
//

import Foundation

struct ReviewCandidate: Equatable, Identifiable {
    let answer: ReviewAnswer
    let isCorrect: Bool

    var id: String {
        answer.text
    }
}
