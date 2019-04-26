//
//  CountedSetTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Exercises CountedSets to ensure they work correctly.
class CountedSetTests: XCTestCase {
    /// Tests that counted sets work with adding, counting, and removing objects.
    // swiftlint:disable:next function_body_length
    func testCountedSets() {
        var test = CountedSet<String>()

        XCTAssertEqual(test.count(for: "Unwrap"), 0)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 0)
        XCTAssertTrue(test.isEmpty)

        test.insert("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 1)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 2)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 3)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 3)
        XCTAssertEqual(test.count(for: "unwrap"), 1)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 2)
        XCTAssertFalse(test.isEmpty)

        test.insert("SWIFT")
        XCTAssertEqual(test.count(for: "Unwrap"), 3)
        XCTAssertEqual(test.count(for: "unwrap"), 1)
        XCTAssertEqual(test.count(for: "SWIFT"), 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 2)
        XCTAssertEqual(test.count(for: "unwrap"), 1)
        XCTAssertEqual(test.count(for: "SWIFT"), 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 1)
        XCTAssertEqual(test.count(for: "unwrap"), 1)
        XCTAssertEqual(test.count(for: "SWIFT"), 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 0)
        XCTAssertEqual(test.count(for: "unwrap"), 1)
        XCTAssertEqual(test.count(for: "SWIFT"), 1)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 2)
        XCTAssertFalse(test.isEmpty)

        test.remove("unwrap")
        XCTAssertEqual(test.count(for: "Unwrap"), 0)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 1)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 1)
        XCTAssertFalse(test.isEmpty)

        test.remove("SWIFT")
        XCTAssertEqual(test.count(for: "Unwrap"), 0)
        XCTAssertEqual(test.count(for: "unwrap"), 0)
        XCTAssertEqual(test.count(for: "SWIFT"), 0)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssertEqual(test.count, 0)
        XCTAssertTrue(test.isEmpty)
    }
}
