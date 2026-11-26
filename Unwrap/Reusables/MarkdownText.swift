//
//  MarkdownText.swift
//  Unwrap
//

import SwiftUI

struct MarkdownText: View {
    private let attributedText: AttributedString

    init(markdown: String) {
        attributedText = Self.attributedString(from: markdown)
    }

    var body: some View {
        Text(attributedText)
    }

    static func attributedString(from markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )

        var result = (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)

        for run in result.runs where run.inlinePresentationIntent?.contains(.code) == true {
            result[run.range].inlinePresentationIntent = .stronglyEmphasized
        }

        return result
    }
}
