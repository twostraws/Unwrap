//
//  PracticeFeatureCatalogTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Practice catalog and factories", .serialized)
struct PracticeFeatureCatalogTests {
    struct ExpectedMetadata: Equatable {
        let id: String
        let title: String
        let sessionTitle: String
        let subtitle: String
        let unlockSectionID: String
        let unlockSectionTitle: String
        let symbolName: String
    }

    private static let expectedMetadata = [
        ExpectedMetadata(
            id: "free-coding",
            title: "Free Coding",
            sessionTitle: "Free Coding",
            subtitle: "Write code to solve problems",
            unlockSectionID: "typecasting",
            unlockSectionTitle: "Typecasting",
            symbolName: "keyboard.fill"
        ),
        ExpectedMetadata(
            id: "predict-the-output",
            title: "Predict the Output",
            sessionTitle: "Predict the Output",
            subtitle: "Read code then predict the output",
            unlockSectionID: "functions-summary",
            unlockSectionTitle: "Functions: Summary",
            symbolName: "questionmark.circle.fill"
        ),
        ExpectedMetadata(
            id: "rearrange-the-lines",
            title: "Rearrange the Lines",
            sessionTitle: "Rearrange the Lines",
            subtitle: "Rearrange code to make it build",
            unlockSectionID: "mutability",
            unlockSectionTitle: "Mutability",
            symbolName: "arrow.up.arrow.down"
        ),
        ExpectedMetadata(
            id: "review",
            title: "Review",
            sessionTitle: "Review",
            subtitle: "Go over questions you've already learned",
            unlockSectionID: "variables",
            unlockSectionTitle: "Variables",
            symbolName: "graduationcap.fill"
        ),
        ExpectedMetadata(
            id: "spot-the-error",
            title: "Spot the Error",
            sessionTitle: "Spot the Error",
            subtitle: "Master Swift's type system through examples",
            unlockSectionID: "default-parameters",
            unlockSectionTitle: "Default parameters",
            symbolName: "magnifyingglass"
        ),
        ExpectedMetadata(
            id: "tap-to-code",
            title: "Tap to Code",
            sessionTitle: "Tap to Code",
            subtitle: "Build working code by tapping components",
            unlockSectionID: "infinite-loops",
            unlockSectionTitle: "Infinite Loops",
            symbolName: "hand.tap.fill"
        ),
        ExpectedMetadata(
            id: "type-practice",
            title: "Type Checker",
            sessionTitle: "Type Practice",
            subtitle: "Identify data types more easily",
            unlockSectionID: "type-annotations",
            unlockSectionTitle: "Type annotations",
            symbolName: "target"
        )
    ]

    @Test("Catalog order and legacy metadata are stable")
    func stableCatalog() {
        let metadata = PracticeKind.allCases.map {
            ExpectedMetadata(
                id: $0.id,
                title: $0.title,
                sessionTitle: $0.sessionTitle,
                subtitle: $0.subtitle,
                unlockSectionID: $0.unlockSectionID,
                unlockSectionTitle: $0.unlockSectionTitle,
                symbolName: $0.symbolName
            )
        }

        #expect(metadata == Self.expectedMetadata)
    }

    @Test("Every activity unlocks only after its exact section has a rating")
    func unlockPolicy() throws {
        let freshUser = User()

        for kind in PracticeKind.allCases {
            #expect(kind.isUnlocked(for: freshUser) == false)

            let unlockedUser = try User.learning([kind.unlockSectionID])
            #expect(kind.isUnlocked(for: unlockedUser))

            let siblingUser = try User.learning(["unrelated-section"])
            #expect(kind.isUnlocked(for: siblingUser) == false)
        }
    }

    @Test("Locked activities use the original alert copy")
    func lockedAlertCopy() {
        #expect(
            PracticeKind.typeChecker.lockedMessage
                == "You need to complete the chapter \"Type annotations\" before you can practice this."
        )
    }
}
