//
//  SyntaxThemePalette.swift
//  Unwrap
//

nonisolated struct SyntaxThemePalette: Equatable, Sendable {
    let backgroundColor: SyntaxColor
    let foregroundColor: SyntaxColor
    private let styles: [SyntaxTokenKind: SyntaxTextStyle]

    init(
        backgroundColor: SyntaxColor,
        foregroundColor: SyntaxColor,
        styles: [SyntaxTokenKind: SyntaxTextStyle]
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.styles = styles
    }

    func style(for kind: SyntaxTokenKind) -> SyntaxTextStyle {
        styles[kind] ?? SyntaxTextStyle(foregroundColor: foregroundColor)
    }
}
