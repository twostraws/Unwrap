//
//  Unwrap.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import UIKit

enum Unwrap {
    /// The URL where users can go to share this app.
    static let appURL = URL(staticString: "https://github.com/twostraws/unwrap")

    /// The static chapters for the app. These can be loaded up front – they never change while the app is running.
    static let chapters = Bundle.main.decode([Chapter].self, from: "Chapters.json")

    /// The basic font used for code in the app, scaled up for Dynamic Type.
    static var codeFont: UIFont {
        let metrics = UIFontMetrics(forTextStyle: .body)
        let baseFont = UIFont(name: "Menlo", size: 17) ?? UIFont.systemFont(ofSize: 17)
        return metrics.scaledFont(for: baseFont)
    }
}
