//
//  AttributedStringSyntaxRenderer.swift
//  Unwrap
//

import Foundation
import SwiftUI

nonisolated struct AttributedStringSyntaxRenderer: SyntaxRenderer {
    func render(
        _ highlightedCode: HighlightedCode,
        theme: SyntaxTheme,
        variant: SyntaxThemeVariant,
        options: SyntaxRenderingOptions = SyntaxRenderingOptions()
    ) -> AttributedString {
        let palette = theme.palette(for: variant)
        let baseFont = Font.system(.body, design: .monospaced)
        var result = AttributedString(highlightedCode.source)
        result.font = baseFont
        result.foregroundColor = palette.foregroundColor.swiftUIColor

        for token in highlightedCode.tokens {
            guard let attributedRange = Range(token.range, in: result) else { continue }
            let style = palette.style(for: token.kind)
            var font = baseFont

            if style.isBold {
                font = font.bold()
            }

            if style.isItalic {
                font = font.italic()
            }

            result[attributedRange].foregroundColor = style.swiftUIColor
            result[attributedRange].font = font
            result[attributedRange].underlineStyle = style.isUnderlined ? .single : nil
        }

        return result
    }
}
