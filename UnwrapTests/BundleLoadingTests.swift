//
//  BundleLoadingTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// Tests that content can be loaded from our app bundle.
class BundleLoadingTests: XCTestCase {
    /// Tests decoding a type from JSON.
    func testDecoding() {
        _ = Bundle.main.decode([TourItem].self, from: "Tour.json")
    }

    /// Tests loading a Data instance from the app bundle.
    func testDataLoading() {
        _ = Data(bundleName: "variables.json")
    }

    /// Tests loading a String instance from the app bundle.
    func testStringLoading() {
        _ = String(bundleName: "variables.json")
    }

    /// Tests that strings can be formatted in a bundle-friendly way.
    func testStringBundleNames() {
        let testString = "This?is , a:test'"
        XCTAssertEqual(testString.bundleName, "thisis--atest")
    }

    /// Tests loading the wrapper HTML from our bundle.
    func testLoadingWrapperHTML() {
        _ = String.wrapperHTML(allowTheming: true)
    }

    /// Tests loading a named color instance from the app bundle.
    func testNamedColors() {
        _ = UIColor(bundleName: "Primary")
    }

    /// Tests loading a UIImage instance from the app bundle.
    func testImages() {
        _ = UIImage(bundleName: "Rank Level 1")
    }
}
