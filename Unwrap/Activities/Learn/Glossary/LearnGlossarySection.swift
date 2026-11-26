//
//  LearnGlossarySection.swift
//  Unwrap
//

import Foundation

struct LearnGlossarySection: Equatable, Identifiable {
    let title: String
    let entries: [LearnGlossaryEntry]

    var id: String {
        title
    }
}
