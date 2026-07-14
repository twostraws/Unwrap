//
//  BundleLoadingTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

/// Tests that content can be loaded from our app bundle.
@Suite("Bundle loading")
struct BundleLoadingTests {
    /// Tests decoding a type from JSON.
    @Test("JSON resources decode")
    func decoding() {
        let items = Bundle.main.decode([TourItem].self, from: "Tour.json")
        #expect(items.isEmpty == false)
    }

    /// Tests loading a Data instance from the app bundle.
    @Test("Data resources load")
    func dataLoading() {
        let data = Data(bundleName: "variables.json")
        #expect(data.isEmpty == false)
    }

    /// Tests loading a String instance from the app bundle.
    @Test("String resources load")
    func stringLoading() {
        let string = String(bundleName: "variables.json")
        #expect(string.isEmpty == false)
    }

    /// Tests that strings can be formatted in a bundle-friendly way.
    @Test("Strings form bundle names")
    func stringBundleNames() {
        let testString = "This?is , a:test'"
        #expect(testString.bundleName == "thisis--atest")
    }

    /// Tests loading the wrapper HTML from our bundle.
    @Test("Wrapper HTML loads")
    func loadingWrapperHTML() {
        let wrapper = String.wrapperHTML(width: 320)
        #expect(wrapper.isEmpty == false)
    }

    /// Tests loading a named color instance from the app bundle.
    @Test("Named colors load")
    func namedColors() {
        _ = UIColor(bundleName: "Primary")
    }

    /// Tests loading a UIImage instance from the app bundle.
    @Test("Images load")
    func images() {
        _ = UIImage(bundleName: "Rank Level 1")
    }
}
