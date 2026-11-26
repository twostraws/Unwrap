//
//  LessonContent.swift
//  Unwrap
//

import Foundation

struct LessonContent: Decodable {
    let blocks: [LessonBlock]

    private enum CodingKeys: String, CodingKey {
        case blocks = "content"
    }
}
