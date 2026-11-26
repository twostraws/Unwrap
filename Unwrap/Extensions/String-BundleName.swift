//
//  String-BundleName.swift
//  Unwrap
//

import Foundation

extension String {
    /// Converts display text to the filename convention used by bundled content.
    var bundleName: String {
        replacing("?", with: "")
            .replacing("'", with: "")
            .replacing(":", with: "")
            .replacing(",", with: "")
            .lowercased()
            .replacing(" ", with: "-")
    }
}
