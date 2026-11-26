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

/// Tests that bundled content is reachable through the app-hosted resource boundary.
@Suite("Bundled content")
struct ContentTests {
    private var bundle: Bundle {
        .main
    }

    @Test("Top-level JSON fixtures decode into native models")
    func jsonFixturesDecode() throws {
        let home = try HomeContent(bundle: bundle)
        let freeCoding = try bundle.decode([FreeCodingContent].self, from: "FreeCoding.json")
        let predictOutput = try bundle.decode(
            [PredictOutputContent].self,
            from: "PredictTheOutput.json"
        )
        let rearrangeLines = try bundle.decode(
            [RearrangeLinesContent].self,
            from: "RearrangeTheLines.json"
        )
        let spotError = try bundle.decode([SpotErrorContent].self, from: "SpotTheError.json")
        let tapToCode = try bundle.decode([TapToCodeContent].self, from: "TapToCode.json")

        #expect(home.tourItems.count == 5)
        #expect(home.helpItems.count == 7)
        #expect(home.badges.count == 24)
        #expect(home.creditsMarkdown.isEmpty == false)
        #expect(freeCoding.isEmpty == false)
        #expect(predictOutput.isEmpty == false)
        #expect(rearrangeLines.isEmpty == false)
        #expect(spotError.isEmpty == false)
        #expect(tapToCode.isEmpty == false)
    }

    @Test("Every lesson review uses the shared review model")
    func lessonReviewsDecode() throws {
        for title in Unwrap.chapters.flatMap(\.sections) {
            let lesson = try Lesson(title: title, bundle: bundle)
            let decodedReview = try bundle.decode(
                ReviewContent.self,
                from: "\(lesson.id).json"
            )

            #expect(decodedReview.title == lesson.title)
            #expect(lesson.review == decodedReview)
        }
    }
}
