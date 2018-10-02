//
//  NSAttributedString-Formatting.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import UIKit

extension NSAttributedString {
    /// Takes a chunk of HTML in a string and wraps it in our HTML to give it common styling.
    convenience init(formattedAsHTML bodyContents: String) {
        // merge the wrapper with this page's content
        var finalHTML = String.wrapperHTML(allowTheming: false).replacingOccurrences(of: "[BODY]", with: bodyContents).trimmingCharacters(in: .whitespacesAndNewlines)

        let data = Data(finalHTML.utf8)

        do {
            try self.init(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            fatalError("Unable to wrap string in HTML: \(bodyContents).")
        }
    }

    /// A simple initializer that loads a chapter filename into a string, wraps it in HTML, then adds in our video.
    convenience init(chapterName: String) {
        let bodyContents = String(bundleName: "\(chapterName).html")

        // Merge the wrapper with this page's content.
        var finalHTML = String.wrapperHTML(allowTheming: true).replacingOccurrences(of: "[BODY]", with: bodyContents)

        // Finally, replace any instances of [VIDEO-NUMBER] with the correct chapter and section.
        finalHTML = finalHTML.replacingOccurrences(of: "[VIDEO-NUMBER]", with: chapterName)

        let data = Data(finalHTML.utf8)

        do {
            try self.init(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            fatalError("Unable to parse chapter: \(chapterName).")
        }
    }

    /// Creates a two-line attributed string, with a regular title and a large subtitle. Used in various places including the Home tab, where we show the user's points.
    static func makeTitle(_ title: String, subtitle: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body), .paragraphStyle: paragraphStyle]
        let numberAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .largeTitle), .paragraphStyle: paragraphStyle]

        let title = NSMutableAttributedString(string: "\(title.uppercased())\n", attributes: titleAttributes)
        let number = NSAttributedString(string: subtitle, attributes: numberAttributes)

        title.append(number)
        return title
    }
}
