//
//  BundleLoading.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A collection of helpful methods for loading data from our app bundle.
extension Bundle {
    /// Decodes one object type from a JSON filename stored in our bundle.
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let json = url(forResource: filename, withExtension: nil) else {
            fatalError("Failed to locate \(filename) in app bundle.")
        }

        guard let jsonData = try? Data(contentsOf: json) else {
            fatalError("Failed to load \(filename) from app bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let result = try? decoder.decode(T.self, from: jsonData) else {
            fatalError("Failed to decode \(filename) from app bundle.")
        }

        return result
    }
}

extension Data {
    /// Creates a Data instance from a filename in our bundle.
    init(bundleName: String) {
        guard let url = Bundle.main.url(forResource: bundleName, withExtension: nil) else {
            fatalError("Unable to locate \(bundleName).")
        }

        guard let contents = try? Data(contentsOf: url) else {
            fatalError("Unable to read \(bundleName).")
        }

        self = contents
    }
}

extension String {
    /// Converts a string to the format used in filenames in the app bundle, e.g. "hello, world" becomes "hello-world".
    var bundleName: String {
        let cleaned = self.replacingOccurrences(of: "[\\?':,]", with: "", options: .regularExpression)
        return cleaned.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    /// Creates a String instance from a filename in our bundle.
    init(bundleName: String) {
        guard let url = Bundle.main.url(forResource: bundleName, withExtension: nil) else {
            fatalError("Unable to locate \(bundleName).")
        }

        guard let contents = try? String(contentsOf: url) else {
            fatalError("Unable to read \(bundleName).")
        }

        self = contents
    }

    /// Loads the HTML wrapper from our bundle.
    static func wrapperHTML(width: CGFloat, slimLayout: Bool = false) -> String {
        var wrapperContents: String

        if slimLayout {
            wrapperContents = String(bundleName: "HTMLWrapper-Slim.html")
        } else {
            wrapperContents = String(bundleName: "HTMLWrapper.html")
        }

        // Replace relative URLs of images with absolute URLs.
        wrapperContents = wrapperContents.replacingOccurrences(of: "<img src=\"", with: "<img src=\"\(Bundle.main.resourceURL!)/")

        // Add in the currently selected theme.
        let currentTheme: String

        if UIApplication.activeTraitCollection.userInterfaceStyle == .dark {
            currentTheme = "Dark"
        } else {
            currentTheme = "Light"
        }

        var styleContents = String(bundleName: "\(currentTheme)Theme.css")

        // Scale up fonts based on Dynamic Type.
        let metrics = UIFontMetrics(forTextStyle: .body)
        let scaledSize = metrics.scaledValue(for: 140)
        styleContents = styleContents.replacingOccurrences(of: "[FONTSIZE]", with: "\(scaledSize)")

        // Force images to be the natural screen width.
        styleContents = styleContents.replacingOccurrences(of: "[IMAGEWIDTH]", with: "\(width)px")

        // Now merge in our adjusted CSS with the main HTML wrapper.
        wrapperContents = wrapperContents.replacingOccurrences(of: "[STYLE]", with: styleContents)

        return wrapperContents
    }
}

extension UIColor {
    /// Creates a UIColor instance from a filename in our bundle.
    convenience init(bundleName: String) {
        self.init(named: bundleName)!
    }
}

extension UIImage {
    /// Creates a UIImage instance from a filename in our bundle.
    convenience init(bundleName: String) {
        self.init(named: bundleName)!
    }
}
