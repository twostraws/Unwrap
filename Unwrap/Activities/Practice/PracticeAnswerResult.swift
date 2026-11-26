//
//  PracticeAnswerResult.swift
//  Unwrap
//

import Foundation

enum PracticeAnswerResult: Equatable {
    case correct
    case incorrect
    case retryableIncorrect

    var isCorrect: Bool {
        self == .correct
    }
}
