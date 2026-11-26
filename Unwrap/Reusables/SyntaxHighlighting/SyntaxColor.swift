//
//  SyntaxColor.swift
//  Unwrap
//

import Foundation
import SwiftUI

/// A renderer-independent sRGB color used by syntax themes.
nonisolated struct SyntaxColor: Equatable, Hashable, Sendable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red.clamped(to: 0...1)
        self.green = green.clamped(to: 0...1)
        self.blue = blue.clamped(to: 0...1)
        self.alpha = alpha.clamped(to: 0...1)
    }

    static func rgb(_ red: Int, _ green: Int, _ blue: Int, alpha: Double = 1) -> SyntaxColor {
        SyntaxColor(
            red: Double(red.clamped(to: 0...255)) / 255,
            green: Double(green.clamped(to: 0...255)) / 255,
            blue: Double(blue.clamped(to: 0...255)) / 255,
            alpha: alpha
        )
    }

    var cssHex: String {
        let redByte = Int((red * 255).rounded())
        let greenByte = Int((green * 255).rounded())
        let blueByte = Int((blue * 255).rounded())
        return "#\(Self.hexByte(redByte))\(Self.hexByte(greenByte))\(Self.hexByte(blueByte))"
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    private static func hexByte(_ value: Int) -> String {
        let digits = Array("0123456789ABCDEF")
        return String([digits[value / 16], digits[value % 16]])
    }
}

private extension Comparable {
    nonisolated func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
