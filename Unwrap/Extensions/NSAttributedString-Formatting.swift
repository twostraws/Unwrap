//
//  NSAttributedString-Formatting.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension NSAttributedString {
    /// A simple initializer that loads a chapter filename into a string, wraps it in HTML, then adds in our video.
    convenience init(chapterName: String, width: CGFloat) {
        let bodyContents = String(bundleName: "\(chapterName).html")

        // Merge the wrapper with this page's content.
        var finalHTML = String.wrapperHTML(width: width).replacingOccurrences(of: "[BODY]", with: bodyContents)

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

    /// Adds an extra bold font attribute to the entire string. This is used to show explanation for code questions.
    func formattedAsExplanation() -> NSAttributedString {
        let returnValue = NSMutableAttributedString(attributedString: self)

        returnValue.addAttribute(.font, value: Unwrap.scaledExtraBoldFont, range: NSRange(location: 0, length: returnValue.length))

        return returnValue
    }

    // concatenate attributed strings
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}
