//
//  CountedSetTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Testing
@testable import Unwrap

/// Exercises CountedSets to ensure they work correctly.
@Suite("CountedSet state transitions")
struct CountedSetTests {
    struct Scenario: CustomStringConvertible {
        let name: String
        let insertions: [String]
        let removals: [String]
        let expectedCounts: [String: Int]

        var description: String { name }
    }

    @Test(
        "Adding and removing values maintains occurrence and distinct-value counts",
        arguments: [
            Scenario(name: "empty", insertions: [], removals: [], expectedCounts: [:]),
            Scenario(name: "one Unwrap", insertions: ["Unwrap"], removals: [], expectedCounts: ["Unwrap": 1]),
            Scenario(name: "two Unwrap", insertions: ["Unwrap", "Unwrap"], removals: [], expectedCounts: ["Unwrap": 2]),
            Scenario(
                name: "three Unwrap",
                insertions: ["Unwrap", "Unwrap", "Unwrap"],
                removals: [],
                expectedCounts: ["Unwrap": 3]
            ),
            Scenario(
                name: "case-sensitive values",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap"],
                removals: [],
                expectedCounts: ["Unwrap": 3, "unwrap": 1]
            ),
            Scenario(
                name: "three distinct values",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: [],
                expectedCounts: ["Unwrap": 3, "unwrap": 1, "SWIFT": 1]
            ),
            Scenario(
                name: "remove one duplicate",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: ["Unwrap"],
                expectedCounts: ["Unwrap": 2, "unwrap": 1, "SWIFT": 1]
            ),
            Scenario(
                name: "remove two duplicates",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: ["Unwrap", "Unwrap"],
                expectedCounts: ["Unwrap": 1, "unwrap": 1, "SWIFT": 1]
            ),
            Scenario(
                name: "remove the final duplicate",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: ["Unwrap", "Unwrap", "Unwrap"],
                expectedCounts: ["unwrap": 1, "SWIFT": 1]
            ),
            Scenario(
                name: "remove all but one value",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: ["Unwrap", "Unwrap", "Unwrap", "unwrap"],
                expectedCounts: ["SWIFT": 1]
            ),
            Scenario(
                name: "remove every value",
                insertions: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                removals: ["Unwrap", "Unwrap", "Unwrap", "unwrap", "SWIFT"],
                expectedCounts: [:]
            )
        ]
    )
    func stateTransitions(_ scenario: Scenario) {
        var countedSet = CountedSet<String>()

        for value in scenario.insertions {
            countedSet.insert(value)
        }

        for value in scenario.removals {
            countedSet.remove(value)
        }

        for value in ["Unwrap", "unwrap", "SWIFT"] {
            let expectedCount = scenario.expectedCounts[value, default: 0]
            #expect(countedSet.count(for: value) == expectedCount)
            #expect(countedSet.contains(value) == (expectedCount > 0))
        }

        #expect(countedSet.count == scenario.expectedCounts.count)
        #expect(countedSet.isEmpty == scenario.expectedCounts.isEmpty)
    }
}
