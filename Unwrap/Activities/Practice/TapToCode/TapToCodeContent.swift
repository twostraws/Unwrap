//
//  TapToCodeContent.swift
//  Unwrap
//

import Foundation

struct TapToCodeContent: Decodable, Equatable {
    let question: String
    let existingCode: String
    let components: [String]
}
