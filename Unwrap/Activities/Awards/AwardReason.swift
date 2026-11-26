//
//  AwardReason.swift
//  Unwrap
//

import Foundation

enum AwardReason: Equatable {
    case challenge
    case learning(section: String)
    case practice(kind: String)
    case review(section: String)
}
