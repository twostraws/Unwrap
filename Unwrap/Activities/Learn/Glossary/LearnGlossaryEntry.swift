//
//  LearnGlossaryEntry.swift
//  Unwrap
//

import Foundation

struct LearnGlossaryEntry: Codable, Equatable, Identifiable {
    let term: String
    let description: String

    var id: String {
        term
    }
}
