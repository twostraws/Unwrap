//
//  SyntaxHighlightingThemeTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Syntax highlighting themes")
struct SyntaxHighlightingThemeTests {
    @Test("Xcode keeps the original UIKit colors in light and dark variants")
    func xcodeTheme() {
        let light = SyntaxTheme.xcode.palette(for: .light)
        let dark = SyntaxTheme.xcode.palette(for: .dark)

        #expect(light.style(for: .comment).foregroundColor.cssHex == "#007400")
        #expect(light.style(for: .keyword).foregroundColor.cssHex == "#AA0D91")
        #expect(light.style(for: .number).foregroundColor.cssHex == "#1C00CF")
        #expect(light.style(for: .string).foregroundColor.cssHex == "#C41A16")
        #expect(dark.style(for: .comment).foregroundColor.cssHex == "#6C7986")
        #expect(dark.style(for: .keyword).foregroundColor.cssHex == "#FC5FA3")
        #expect(dark.style(for: .number).foregroundColor.cssHex == "#9686F5")
        #expect(dark.style(for: .string).foregroundColor.cssHex == "#FC6A5D")
    }

    @Test("Xcode draws punctuation and operators in black or white, leaving identifiers and types alone")
    func xcodePunctuation() {
        let light = SyntaxTheme.xcode.palette(for: .light)
        let dark = SyntaxTheme.xcode.palette(for: .dark)

        #expect(light.foregroundColor.cssHex == "#000000")
        #expect(light.style(for: .operator).foregroundColor.cssHex == "#000000")
        #expect(light.style(for: .identifier).foregroundColor.cssHex == "#3F6E74")
        #expect(light.style(for: .className).foregroundColor.cssHex == "#3F6E74")
        #expect(dark.foregroundColor.cssHex == "#FFFFFF")
        #expect(dark.style(for: .operator).foregroundColor.cssHex == "#FFFFFF")
        #expect(dark.style(for: .identifier).foregroundColor.cssHex == "#7AC8B6")
        #expect(dark.style(for: .className).foregroundColor.cssHex == "#7AC8B6")
    }

    @Test("GitHub uses distinct Primer light and dark syntax palettes")
    func githubTheme() {
        let light = SyntaxTheme.github.palette(for: .light)
        let dark = SyntaxTheme.github.palette(for: .dark)

        #expect(light.style(for: .comment).foregroundColor.cssHex == "#6E7781")
        #expect(light.style(for: .keyword).foregroundColor.cssHex == "#CF222E")
        #expect(light.style(for: .string).foregroundColor.cssHex == "#0A3069")
        #expect(dark.style(for: .comment).foregroundColor.cssHex == "#8B949E")
        #expect(dark.style(for: .keyword).foregroundColor.cssHex == "#FF7B72")
        #expect(dark.style(for: .string).foregroundColor.cssHex == "#A5D6FF")
        #expect(light.backgroundColor != dark.backgroundColor)
    }

    @Test("Every semantic token has a resolved style in every built-in variant")
    func completeThemes() {
        for theme in SyntaxTheme.builtIn {
            for variant in SyntaxThemeVariant.allCases {
                let palette = theme.palette(for: variant)

                for kind in SyntaxTokenKind.allCases {
                    #expect(palette.style(for: kind).foregroundColor.alpha > 0)
                }
            }
        }
    }

    @Test("Callers can define complete custom theme families")
    func customTheme() {
        let light = SyntaxThemePalette(
            backgroundColor: .rgb(255, 255, 255),
            foregroundColor: .rgb(10, 20, 30),
            styles: [.keyword: SyntaxTextStyle(foregroundColor: .rgb(200, 0, 0), isBold: true)]
        )
        let dark = SyntaxThemePalette(
            backgroundColor: .rgb(0, 0, 0),
            foregroundColor: .rgb(240, 240, 240),
            styles: [.keyword: SyntaxTextStyle(foregroundColor: .rgb(255, 100, 100), isBold: true)]
        )
        let theme = SyntaxTheme(id: "custom", name: "Custom", light: light, dark: dark)

        #expect(theme.palette(for: .light).style(for: .keyword).foregroundColor.cssHex == "#C80000")
        #expect(theme.palette(for: .dark).style(for: .keyword).foregroundColor.cssHex == "#FF6464")
        #expect(theme.palette(for: .light).style(for: .string).foregroundColor.cssHex == "#0A141E")
    }
}
