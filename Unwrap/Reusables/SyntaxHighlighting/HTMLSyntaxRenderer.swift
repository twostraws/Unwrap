//
//  HTMLSyntaxRenderer.swift
//  Unwrap
//

import Foundation

nonisolated struct HTMLSyntaxRenderer: SyntaxRenderer {
    func render(
        _ highlightedCode: HighlightedCode,
        theme: SyntaxTheme,
        variant: SyntaxThemeVariant,
        options: SyntaxRenderingOptions = SyntaxRenderingOptions()
    ) -> String {
        let palette = theme.palette(for: variant)
        let wrappingStyles: String

        switch options.lineWrapping {
        case .disabled:
            wrappingStyles = "white-space: pre; overflow-x: auto;"
        case .enabled:
            wrappingStyles = "white-space: pre-wrap; overflow-wrap: anywhere;"
        }

        let preStyle = [
            "margin: 0;",
            "box-sizing: border-box;",
            "background-color: \(palette.backgroundColor.cssHex);",
            "color: \(palette.foregroundColor.cssHex);",
            wrappingStyles,
            "hyphens: none;",
            "-webkit-hyphens: none;"
        ].joined(separator: " ")

        var renderedSource = ""
        var cursor = highlightedCode.source.startIndex

        for token in highlightedCode.tokens where token.range.lowerBound >= cursor {
            renderedSource += escape(highlightedCode.source[cursor..<token.range.lowerBound])
            let style = palette.style(for: token.kind)
            renderedSource += "<span class=\"token \(token.kind.rawValue)\" style=\"\(css(for: style))\">"
            renderedSource += escape(highlightedCode.source[token.range])
            renderedSource += "</span>"
            cursor = token.range.upperBound
        }

        renderedSource += escape(highlightedCode.source[cursor...])

        return "<pre data-theme=\"\(escapeAttribute(theme.id))\" data-variant=\"\(variant.rawValue)\" style=\"\(preStyle)\"><code class=\"language-\(escapeAttribute(highlightedCode.language.rawValue))\">\(renderedSource)</code></pre>"
    }

    private func css(for style: SyntaxTextStyle) -> String {
        var declarations = ["color: \(style.foregroundColor.cssHex);"]

        if style.isBold {
            declarations.append("font-weight: 700;")
        }

        if style.isItalic {
            declarations.append("font-style: italic;")
        }

        if style.isUnderlined {
            declarations.append("text-decoration: underline;")
        }

        return declarations.joined(separator: " ")
    }

    private func escape<S: StringProtocol>(_ value: S) -> String {
        var result = ""
        result.reserveCapacity(value.utf8.count)

        for character in value {
            switch character {
            case "&":
                result += "&amp;"
            case "<":
                result += "&lt;"
            case ">":
                result += "&gt;"
            case "\"":
                result += "&quot;"
            case "'":
                result += "&#39;"
            default:
                result.append(character)
            }
        }

        return result
    }

    private func escapeAttribute(_ value: String) -> String {
        escape(value)
    }
}
