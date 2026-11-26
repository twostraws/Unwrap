//
//  SwiftCodeHighlighter.swift
//  Unwrap
//

import SwiftUI

struct SwiftCodeHighlighter {
    func attributedString(
        for source: String,
        colorScheme: ColorScheme,
        foregroundColor: Color? = nil
    ) -> AttributedString {
        guard let highlightedCode = try? SyntaxHighlighter().highlight(source, language: .swift) else {
            var fallback = AttributedString(source)
            fallback.font = .system(.body, design: .monospaced)
            fallback.foregroundColor = foregroundColor
            return fallback
        }

        var result = AttributedStringSyntaxRenderer().render(
            highlightedCode,
            theme: .xcode,
            variant: colorScheme == .dark ? .dark : .light
        )

        // Attributed colors take precedence over a containing view's foreground style.
        // Feedback rows need one readable color over their correct/incorrect background.
        if let foregroundColor {
            result.foregroundColor = foregroundColor
        }

        return result
    }
}
