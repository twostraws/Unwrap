//
//  SyntaxHighlightedCodeView.swift
//  Unwrap
//

import SwiftUI

struct SyntaxHighlightedCodeView: View {
    @Environment(\.colorScheme) private var colorScheme

    let source: String
    let language: SyntaxLanguage
    let theme: SyntaxTheme
    let lineWrapping: CodeLineWrapping

    init(
        source: String,
        language: SyntaxLanguage = .swift,
        theme: SyntaxTheme = .xcode,
        lineWrapping: CodeLineWrapping = .disabled
    ) {
        self.source = source
        self.language = language
        self.theme = theme
        self.lineWrapping = lineWrapping
    }

    var body: some View {
        let variant: SyntaxThemeVariant = colorScheme == .dark ? .dark : .light
        let attributedCode = highlightedCode(variant: variant)

        switch lineWrapping {
        case .disabled:
            ScrollView(.horizontal) {
                SyntaxHighlightedCodeText(
                    attributedCode: attributedCode,
                    source: source,
                    lineWrapping: lineWrapping
                )
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.palette(for: variant).backgroundColor.swiftUIColor, ignoresSafeAreaEdges: [])
        case .enabled:
            SyntaxHighlightedCodeText(
                attributedCode: attributedCode,
                source: source,
                lineWrapping: lineWrapping
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.palette(for: variant).backgroundColor.swiftUIColor, ignoresSafeAreaEdges: [])
        }
    }

    private func highlightedCode(variant: SyntaxThemeVariant) -> AttributedString {
        guard let highlightedCode = try? SyntaxHighlighter().highlight(source, language: language) else {
            var fallback = AttributedString(source)
            fallback.font = .system(.body, design: .monospaced)
            return fallback
        }

        return AttributedStringSyntaxRenderer().render(
            highlightedCode,
            theme: theme,
            variant: variant,
            options: SyntaxRenderingOptions(lineWrapping: lineWrapping)
        )
    }
}
