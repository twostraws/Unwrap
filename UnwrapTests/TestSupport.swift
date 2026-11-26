//
//  TestSupport.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

nonisolated extension Tag {
    /// Marks tests describing correct behavior the app doesn't have yet. They fail until the bug is fixed.
    @Tag static var exposesBug: Self
}

/// Replays a fixed list of choices so a test can force one exact shuffle or selection.
final class ScriptedRandomSource: RandomProviding {
    private var values: [Int]

    init(_ values: [Int]) {
        self.values = values
    }

    func nextInt(in range: ClosedRange<Int>) -> Int {
        guard values.isEmpty == false else { return range.lowerBound }

        let value = values.removeFirst()
        precondition(range.contains(value), "Scripted value \(value) is outside \(range).")
        return value
    }
}

extension User {
    /// Creates a user who has learned the given sections, without saving each one to UserDefaults along the way.
    static func learning(_ sections: [String]) throws -> User {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(User())
        var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["learnedSections"] = sections

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(User.self, from: JSONSerialization.data(withJSONObject: object))
    }

    /// Creates a user who has learned every shipped section, which unlocks every kind of practice.
    static func learningEverything() throws -> User {
        try learning(Unwrap.chapters.flatMap(\.sections).map(\.bundleName))
    }
}
