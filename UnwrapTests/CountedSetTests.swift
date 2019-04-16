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

        XCTAssert(test.count(for: "Unwrap") == 0)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 0)
        XCTAssertTrue(test.isEmpty)

        test.insert("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 1)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 2)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 3)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 1)
        XCTAssertFalse(test.isEmpty)

        test.insert("unwrap")
        XCTAssert(test.count(for: "Unwrap") == 3)
        XCTAssert(test.count(for: "unwrap") == 1)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 2)
        XCTAssertFalse(test.isEmpty)

        test.insert("SWIFT")
        XCTAssert(test.count(for: "Unwrap") == 3)
        XCTAssert(test.count(for: "unwrap") == 1)
        XCTAssert(test.count(for: "SWIFT") == 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssert(test.count == 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 2)
        XCTAssert(test.count(for: "unwrap") == 1)
        XCTAssert(test.count(for: "SWIFT") == 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssert(test.count == 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 1)
        XCTAssert(test.count(for: "unwrap") == 1)
        XCTAssert(test.count(for: "SWIFT") == 1)
        XCTAssertTrue(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssert(test.count == 3)
        XCTAssertFalse(test.isEmpty)

        test.remove("Unwrap")
        XCTAssert(test.count(for: "Unwrap") == 0)
        XCTAssert(test.count(for: "unwrap") == 1)
        XCTAssert(test.count(for: "SWIFT") == 1)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertTrue(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssert(test.count == 2)
        XCTAssertFalse(test.isEmpty)

        test.remove("unwrap")
        XCTAssert(test.count(for: "Unwrap") == 0)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 1)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertTrue(test.contains("SWIFT"))
        XCTAssert(test.count == 1)
        XCTAssertFalse(test.isEmpty)

        test.remove("SWIFT")
        XCTAssert(test.count(for: "Unwrap") == 0)
        XCTAssert(test.count(for: "unwrap") == 0)
        XCTAssert(test.count(for: "SWIFT") == 0)
        XCTAssertFalse(test.contains("Unwrap"))
        XCTAssertFalse(test.contains("unwrap"))
        XCTAssertFalse(test.contains("SWIFT"))
        XCTAssert(test.count == 0)
        XCTAssertTrue(test.isEmpty)
    }
}
