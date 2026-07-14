//
//  ContentTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
@testable import Unwrap

/// Tests that all our bundled content is structurally correct and readable.
@Suite("Bundled content")
struct ContentTests {
    private nonisolated struct ChapterTestMetadata: Decodable {
        let sections: [String]
    }

    nonisolated enum JSONFixture: CaseIterable {
        case tour
        case help
        case badges
        case chapters
        case freeCoding
        case predictTheOutput
        case rearrangeTheLines
        case spotTheError
        case tapToCode
    }

    private nonisolated enum ChapterFixtures {
        static let sectionNames = loadSectionNames()

        private static func loadSectionNames() -> [String] {
            guard let jsonURL = Bundle.main.url(forResource: "Chapters.json", withExtension: nil) else {
                preconditionFailure("Unable to locate Chapters.json.")
            }

            do {
                let jsonData = try Data(contentsOf: jsonURL)
                let chapters = try JSONDecoder().decode([ChapterTestMetadata].self, from: jsonData)
                return chapters.flatMap(\.sections)
            } catch {
                preconditionFailure("Unable to decode Chapters.json: \(error)")
            }
        }
    }

    @Test("JSON fixtures decode", arguments: JSONFixture.allCases)
    func jsonFixturesDecode(fixture: JSONFixture) throws {
        switch fixture {
        case .tour:
            _ = try decode([TourItem].self, from: "Tour.json")
        case .help:
            _ = try decode([HelpItem].self, from: "Help.json")
        case .badges:
            _ = try decode([Badge].self, from: "Badges.json")
        case .chapters:
            _ = try decode([Chapter].self, from: "Chapters.json")
        case .freeCoding:
            _ = try decode([FreeCodingQuestion].self, from: "FreeCoding.json")
        case .predictTheOutput:
            _ = try decode([PredictTheOutputQuestion].self, from: "PredictTheOutput.json")
        case .rearrangeTheLines:
            _ = try decode([RearrangeTheLinesQuestion].self, from: "RearrangeTheLines.json")
        case .spotTheError:
            _ = try decode([SpotTheErrorQuestion].self, from: "SpotTheError.json")
        case .tapToCode:
            _ = try decode([TapToCodeQuestion].self, from: "TapToCode.json")
        }
    }

    @Test("Chapter assets are readable", arguments: ChapterFixtures.sectionNames)
    func chapterAssetsAreReadable(sectionName: String) throws {
        let bundleName = sectionName.bundleName
        try requireReadableResource("\(bundleName).html")
        try requireReadableResource("\(bundleName).png")

        if bundleName != "where-now" {
            try requireReadableResource("\(bundleName).mp4")
        }
    }

    @Test("Chapter review JSON decodes", arguments: ChapterFixtures.sectionNames)
    func chapterReviewJSONDecodes(sectionName: String) throws {
        _ = try decode(StudyReview.self, from: "\(sectionName.bundleName).json")
    }

    /// Decodes a type from a bundle filename using the same strategies as the app.
    private func decode<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let jsonURL = try #require(
            Bundle.main.url(forResource: filename, withExtension: nil),
            "Unable to locate \(filename)."
        )
        let jsonData = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: jsonData)
    }

    /// Ensures a named bundle resource exists and can be read.
    private func requireReadableResource(_ filename: String) throws {
        let resourceURL = try #require(
            Bundle.main.url(forResource: filename, withExtension: nil),
            "Unable to locate \(filename)."
        )

        _ = try Data(contentsOf: resourceURL)
    }
}
