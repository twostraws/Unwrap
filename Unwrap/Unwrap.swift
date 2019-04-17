//
//  Unwrap.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

enum Unwrap {
    /// The URL where users can go to share this app.
    static let appURL = URL(staticString: "https://github.com/twostraws/unwrap")

    /// The static chapters for the app. These can be loaded up front – they never change while the app is running.
    static let chapters = Bundle.main.decode([Chapter].self, from: "Chapters.json")

    /// A number that starts as a random value and increments by one whenever it's used, so tests can ensure they don't keep showing duplicates
    private static var entropy = Int.random(in: 1...1000)

    static func getEntropy() -> Int {
        entropy += 1
        return entropy
    }

    /// The basic font used for code in the app, scaled up for Dynamic Type.
    static var codeFont: UIFont {
        let metrics = UIFontMetrics(forTextStyle: .body)
        let baseFont = UIFont(name: "Menlo", size: 17) ?? UIFont.systemFont(ofSize: 17)
        return metrics.scaledFont(for: baseFont)
    }
}
