//
//  LessonBlock.swift
//  Unwrap
//

import Foundation

enum LessonBlock: Decodable, Equatable {
    case text(String)
    case code(String)
    case bullets([String])
    case numbered([String])

    private enum CodingKeys: String, CodingKey {
        case text
        case code
        case bullets
        case numbered
    }

    private struct BlockKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: any Decoder) throws {
        let blockContainer = try decoder.container(keyedBy: BlockKey.self)
        let blockKeys = blockContainer.allKeys

        guard blockKeys.count == 1,
              let blockName = blockKeys.first?.stringValue,
              let key = CodingKeys(rawValue: blockName) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "A lesson block must contain exactly one supported value."
                )
            )
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch key {
        case .text:
            self = try .text(container.decode(String.self, forKey: .text))
        case .code:
            self = try .code(container.decode(String.self, forKey: .code))
        case .bullets:
            self = try .bullets(container.decode([String].self, forKey: .bullets))
        case .numbered:
            self = try .numbered(container.decode([String].self, forKey: .numbered))
        }
    }
}
