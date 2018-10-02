//
//  String-Attributed.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import SavannaKit
import SourceEditor
import UIKit

extension String {
    /// Formats a string by replacing one specific regex with bold. The regex should contain some sort of marker alongside the content inside the marker, for example in "<code>Meh</code>" the "<code>…</code>" part is the marker and "Meh" is the content inside.
    func bold(usingRegex regexString: String) -> NSAttributedString {
        assert(regexString.isEmpty == false, "Empty regular expression strings are not allowed.")

        // Take a base font in regular and bold, then scale it up for Dynamic Type.
        let baseFont = UIFont.systemFont(ofSize: 20)
        let boldFont = UIFont.boldSystemFont(ofSize: 20)

        let metrics = UIFontMetrics(forTextStyle: .body)
        let scaledBaseFont = metrics.scaledFont(for: baseFont)
        let scaledBoldFont = metrics.scaledFont(for: boldFont)

        let baseAttributes = [NSAttributedString.Key.font: scaledBaseFont]
        let boldAttributes = [NSAttributedString.Key.font: scaledBoldFont]

        /// Start with an attributed string of our base text with the base attributes.
        let result = NSMutableAttributedString(string: self, attributes: baseAttributes)

        /// Prepare to look for whatever we've been asked to bold.
        let regex = NSRegularExpression(regexString, options: [.anchorsMatchLines])

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        /// Loop over all the matches backwards, so that as we perform replacements we don't screw up the string lengths for parts we haven't processed yet.
        for match in matches.reversed() {
            let wholeMatchRange = match.range(at: 1)
            let codeMatchRange = match.range(at: 2)

            if let swiftRange = Range(codeMatchRange, in: self) {
                let text = String(self[swiftRange])
                let str = NSAttributedString(string: text, attributes: boldAttributes)
                result.replaceCharacters(in: wholeMatchRange, with: str)
            }
        }

        return result
    }

    /// Processes trivial HTML by bolding instances of code.
    func fromSimpleHTML() -> NSAttributedString {
        return self.bold(usingRegex: "(<code>(.+?)</code>)")
    }

    /// Processes trivial Markdown by bolding instances of headings.
    func fromSimpleMarkdown() -> NSAttributedString {
        return self.bold(usingRegex: "^(# (.+))$")
    }

    /// Adds syntax highlighting to a string using Source Editor.
    func syntaxHighlighted() -> NSAttributedString {
        let theme = User.current.sourceCodeTheme
        let lexer = SwiftLexer()
        let tokens = lexer.getSavannaTokens(input: self)

        return NSMutableAttributedString(source: self, tokens: tokens, theme: theme)
    }
}
