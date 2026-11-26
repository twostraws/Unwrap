//
//  SyntaxTextStyle.swift
//  Unwrap
//

import SwiftUI

nonisolated struct SyntaxTextStyle: Equatable, Hashable, Sendable {
    let foregroundColor: SyntaxColor
    let isBold: Bool
    let isItalic: Bool
    let isUnderlined: Bool

    init(
        foregroundColor: SyntaxColor,
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false
    ) {
        self.foregroundColor = foregroundColor
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
    }

    var swiftUIColor: Color {
        foregroundColor.swiftUIColor
    }
}
