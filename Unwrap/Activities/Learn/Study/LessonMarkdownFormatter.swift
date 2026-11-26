//
//  LessonMarkdownFormatter.swift
//  Unwrap
//

import SwiftUI

struct LessonMarkdownFormatter {
    static func attributedString(from markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        var result = (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)

        for run in result.runs where run.inlinePresentationIntent?.contains(.code) == true {
            result[run.range].font = .system(.body, design: .monospaced)
        }

        return result
    }
}
