//
//  ContentTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that all our JSON files are structurally correct.
class ContentTests: XCTestCase {
    /// Decodes a type from a bundle filename.
    func decode<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let json = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw TestErrors.badPath
        }

        let jsonData = try Data(contentsOf: json)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let result = try decoder.decode(T.self, from: jsonData)
        return result
    }

    /// Tests that the Tour JSON is correct.
    func testTour() throws {
        _ = try decode([TourItem].self, from: "Tour.json")
    }

    /// Tests that the Help JSON is correct.
    func testHelp() throws {
        _ = try decode([HelpItem].self, from: "Help.json")
    }

    /// Tests that the Badges JSON is correct.
    func testBadges() throws {
        _ = try decode([Badge].self, from: "Badges.json")
    }

    /// Tests that the Chapters JSON is correct.
    func testChapters() throws {
        _ = try decode([Chapter].self, from: "Chapters.json")
    }

    /// Tests that the Free Coding JSON is correct.
    func testFreeCoding() throws {
        _ = try decode([FreeCodingQuestion].self, from: "FreeCoding.json")
    }

    /// Tests that the Predict the Output JSON is correct.
    func testPredictTheOutput() throws {
        _ = try decode([PredictTheOutputQuestion].self, from: "PredictTheOutput.json")
    }

    /// Tests that the Rearrange the Lines JSON is correct.
    func testRearrangeTheLines() throws {
        _ = try decode([RearrangeTheLinesQuestion].self, from: "RearrangeTheLines.json")
    }

    /// Tests that the Spot the Error JSON is correct.
    func testSpotTheError() throws {
        _ = try decode([SpotTheErrorQuestion].self, from: "SpotTheError.json")
    }

    /// Tests that the Tap to Code JSON is correct.
    func testTapToCode() throws {
        _ = try decode([TapToCodeQuestion].self, from: "TapToCode.json")
    }

    /// Tests that the chapter HTML, PNG, and movies are correct.
    func testChapterContent() {
        for chapter in Unwrap.chapters {
            for section in chapter.sections {
                _ = Data(bundleName: section.bundleName + ".html")
                _ = Data(bundleName: section.bundleName + ".png")

                // Where Now is the only section without a video.
                if section.bundleName != "where-now" {
                    _ = Data(bundleName: section.bundleName + ".mp4")
                }
            }
        }
    }

    /// Tests that the chapter review JSON is structurally correct.
    func testChapterReviews() throws {
        for chapter in Unwrap.chapters {
            for section in chapter.sections {
                _ = try decode(StudyReview.self, from: "\(section.bundleName).json")
            }
        }
    }
}
