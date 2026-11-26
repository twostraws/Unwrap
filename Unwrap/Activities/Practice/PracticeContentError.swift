//
//  PracticeContentError.swift
//  Unwrap
//

import Foundation

enum PracticeContentError: LocalizedError, Equatable {
    case emptyContent(String)
    case invalidContent(String)
    case noReviewSections

    var errorDescription: String? {
        switch self {
        case .emptyContent(let name):
            "There are no practice questions in \(name)."
        case .invalidContent(let name):
            "The practice content in \(name) is invalid."
        case .noReviewSections:
            "Complete a Learn section before starting Review practice."
        }
    }
}
