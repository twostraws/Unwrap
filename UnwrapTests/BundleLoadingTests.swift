//
//  BundleLoadingTests.swift
//  UnwrapTests
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import Testing
@testable import Unwrap

/// Tests the bundle-loading helpers used by production code.
@Suite("Bundle loading")
struct BundleLoadingTests {
    private var bundle: Bundle {
        .main
    }

    @Test("JSON resources decode")
    func decoding() throws {
        let items = try bundle.decode([TourItem].self, from: "Tour.json")

        #expect(items.count == 5)
    }

    @Test("Data resources load")
    func dataLoading() throws {
        let data = try bundle.data(named: "variables.json")

        #expect(data.isEmpty == false)
    }

    @Test("Text resources load")
    func textLoading() throws {
        let text = try bundle.text(named: "Credits.md")

        #expect(text.isEmpty == false)
        #expect(text.contains("Unwrap was developed by Paul Hudson"))
    }

    @Test("Resource URLs are local and readable")
    func resourceURLs() throws {
        let url = try #require(bundle.url(named: "variables.mp4"))

        #expect(url.isFileURL)
        #expect(try Data(contentsOf: url).isEmpty == false)
    }

    @Test("Missing resources report their exact name")
    func missingResource() {
        #expect(throws: BundleResourceError.missingResource("not-a-real-resource.json")) {
            try bundle.data(named: "not-a-real-resource.json")
        }
    }

    @Test("Strings form bundle names")
    func stringBundleNames() {
        #expect("This?is , a:test'".bundleName == "thisis--atest")
        #expect("Where now?".bundleName == "where-now")
        #expect(
            "Operators and conditions: Summary".bundleName
                == "operators-and-conditions-summary"
        )
    }
}
