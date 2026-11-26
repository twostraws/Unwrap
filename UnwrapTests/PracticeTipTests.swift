//
//  PracticeTipTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Practice tips")
struct PracticeTipTests {
    @Test("Each tip uses its exact legacy key and copy")
    func legacyMetadata() {
        #expect(PracticeTip.freeCoding.userDefaultsKey == "ShownFreeCoding")
        #expect(PracticeTip.spotTheError.userDefaultsKey == "ShownSpotTheError")
        #expect(PracticeTip.freeCoding.title == "Tip")
        #expect(PracticeTip.spotTheError.title == "Tip")
        #expect(
            PracticeTip.freeCoding.message
                == "Unwrap is able to understand a variety of different solutions to each problem, but it's not perfect. If you enter a valid solution that is not accepted, please let us know so we can add it and make Unwrap better for everyone!"
        )
        #expect(
            PracticeTip.spotTheError.message
                == "You should mentally run the code from top to bottom, meaning that if line 3 says an integer should be returned and line 10 tries to return a string, line 10 is the wrong one."
        )
    }

    @Test("Each tip is presented only once")
    func presentationFlags() throws {
        let suiteName = "PracticeTipTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(PracticeTip.freeCoding.claimPresentation(defaults: defaults))
        #expect(PracticeTip.freeCoding.claimPresentation(defaults: defaults) == false)
        #expect(PracticeTip.spotTheError.claimPresentation(defaults: defaults))
        #expect(PracticeTip.spotTheError.claimPresentation(defaults: defaults) == false)
    }
}
