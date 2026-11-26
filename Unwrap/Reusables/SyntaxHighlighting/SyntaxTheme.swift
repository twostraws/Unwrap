//
//  SyntaxTheme.swift
//  Unwrap
//

nonisolated struct SyntaxTheme: Equatable, Sendable, Identifiable {
    let id: String
    let name: String
    let light: SyntaxThemePalette
    let dark: SyntaxThemePalette

    func palette(for variant: SyntaxThemeVariant) -> SyntaxThemePalette {
        switch variant {
        case .light:
            light
        case .dark:
            dark
        }
    }

    static let xcode = SyntaxTheme(
        id: "xcode",
        name: "Xcode",
        light: SyntaxThemePalette(
            backgroundColor: .rgb(246, 248, 250),
            foregroundColor: .rgb(0, 0, 0),
            styles: xcodeLightStyles
        ),
        dark: SyntaxThemePalette(
            backgroundColor: .rgb(30, 30, 30),
            foregroundColor: .rgb(255, 255, 255),
            styles: xcodeDarkStyles
        )
    )

    static let github = SyntaxTheme(
        id: "github",
        name: "GitHub",
        light: SyntaxThemePalette(
            backgroundColor: .rgb(246, 248, 250),
            foregroundColor: .rgb(36, 41, 47),
            styles: githubLightStyles
        ),
        dark: SyntaxThemePalette(
            backgroundColor: .rgb(22, 27, 34),
            foregroundColor: .rgb(201, 209, 217),
            styles: githubDarkStyles
        )
    )

    static let builtIn: [SyntaxTheme] = [.xcode, .github]

    private static let xcodeLightStyles: [SyntaxTokenKind: SyntaxTextStyle] = styles(
        foreground: .rgb(63, 110, 116),
        colors: [
            .plain: .rgb(0, 0, 0),
            .operator: .rgb(0, 0, 0),
            .comment: .rgb(0, 116, 0),
            .keyword: .rgb(170, 13, 145),
            .number: .rgb(28, 0, 207),
            .string: .rgb(196, 26, 22),
            .className: .rgb(63, 110, 116),
            .function: .rgb(63, 110, 116),
            .variable: .rgb(63, 110, 116),
            .tag: .rgb(63, 110, 116)
        ]
    )

    private static let xcodeDarkStyles: [SyntaxTokenKind: SyntaxTextStyle] = styles(
        foreground: .rgb(122, 200, 182),
        colors: [
            .plain: .rgb(255, 255, 255),
            .operator: .rgb(255, 255, 255),
            .comment: .rgb(108, 121, 134),
            .keyword: .rgb(252, 95, 163),
            .number: .rgb(150, 134, 245),
            .string: .rgb(252, 106, 93),
            .className: .rgb(122, 200, 182),
            .function: .rgb(122, 200, 182),
            .variable: .rgb(122, 200, 182),
            .tag: .rgb(122, 200, 182)
        ]
    )

    private static let githubLightStyles: [SyntaxTokenKind: SyntaxTextStyle] = styles(
        foreground: .rgb(36, 41, 47),
        colors: [
            .comment: .rgb(110, 119, 129),
            .keyword: .rgb(207, 34, 46),
            .number: .rgb(5, 80, 174),
            .string: .rgb(10, 48, 105),
            .className: .rgb(130, 80, 223),
            .function: .rgb(130, 80, 223),
            .variable: .rgb(149, 56, 0),
            .tag: .rgb(17, 99, 41)
        ]
    )

    private static let githubDarkStyles: [SyntaxTokenKind: SyntaxTextStyle] = styles(
        foreground: .rgb(201, 209, 217),
        colors: [
            .comment: .rgb(139, 148, 158),
            .keyword: .rgb(255, 123, 114),
            .number: .rgb(121, 192, 255),
            .string: .rgb(165, 214, 255),
            .className: .rgb(210, 168, 255),
            .function: .rgb(210, 168, 255),
            .variable: .rgb(255, 166, 87),
            .tag: .rgb(126, 231, 135)
        ]
    )

    private static func styles(
        foreground: SyntaxColor,
        colors: [SyntaxTokenKind: SyntaxColor]
    ) -> [SyntaxTokenKind: SyntaxTextStyle] {
        var result = Dictionary(
            uniqueKeysWithValues: SyntaxTokenKind.allCases.map {
                ($0, SyntaxTextStyle(foregroundColor: foreground))
            }
        )

        let comment = colors[.comment, default: foreground]
        let keyword = colors[.keyword, default: foreground]
        let type = colors[.className, default: foreground]
        let variable = colors[.variable, default: foreground]
        let tag = colors[.tag, default: foreground]

        result[.plain] = SyntaxTextStyle(foregroundColor: colors[.plain, default: foreground])
        result[.operator] = SyntaxTextStyle(foregroundColor: colors[.operator, default: foreground])
        result[.comment] = SyntaxTextStyle(foregroundColor: comment, isItalic: true)
        result[.documentationComment] = SyntaxTextStyle(foregroundColor: comment, isItalic: true)
        result[.keyword] = SyntaxTextStyle(foregroundColor: keyword)
        result[.directive] = SyntaxTextStyle(foregroundColor: keyword)
        result[.attribute] = SyntaxTextStyle(foregroundColor: keyword)
        result[.boolean] = SyntaxTextStyle(foregroundColor: keyword)
        result[.number] = SyntaxTextStyle(foregroundColor: colors[.number, default: foreground])
        result[.string] = SyntaxTextStyle(foregroundColor: colors[.string, default: foreground])
        result[.regex] = SyntaxTextStyle(foregroundColor: tag)
        result[.className] = SyntaxTextStyle(foregroundColor: type)
        result[.builtin] = SyntaxTextStyle(foregroundColor: type)
        result[.function] = SyntaxTextStyle(foregroundColor: colors[.function, default: foreground])
        result[.variable] = SyntaxTextStyle(foregroundColor: variable)
        result[.property] = SyntaxTextStyle(foregroundColor: variable)
        result[.tag] = SyntaxTextStyle(foregroundColor: tag)
        result[.selector] = SyntaxTextStyle(foregroundColor: tag)
        result[.title] = SyntaxTextStyle(foregroundColor: type, isBold: true)
        result[.bold] = SyntaxTextStyle(foregroundColor: foreground, isBold: true)
        result[.italic] = SyntaxTextStyle(foregroundColor: foreground, isItalic: true)
        result[.code] = SyntaxTextStyle(foregroundColor: colors[.string, default: foreground])
        return result
    }
}
