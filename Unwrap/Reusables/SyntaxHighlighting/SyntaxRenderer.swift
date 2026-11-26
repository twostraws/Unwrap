//
//  SyntaxRenderer.swift
//  Unwrap
//

nonisolated protocol SyntaxRenderer<Output>: Sendable {
    associatedtype Output

    func render(
        _ highlightedCode: HighlightedCode,
        theme: SyntaxTheme,
        variant: SyntaxThemeVariant,
        options: SyntaxRenderingOptions
    ) -> Output
}
