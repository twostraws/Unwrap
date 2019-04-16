//
//  DarkTheme.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Sourceful
import UIKit

/// A source code theme that has a dark background and light text.
public struct DarkTheme: SourceCodeTheme {
    public var lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Unwrap.codeFont, textColor: Color.darkGray)
    public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color(white: 0.25, alpha: 1), minimumWidth: 32)

    public let backgroundColor = Color.darkGray
    public let font = Unwrap.codeFont

    public func globalAttributes() -> [NSAttributedString.Key: Any] {
        return [.font: Unwrap.codeFont, .foregroundColor: UIColor.white]
    }

    public func color(for syntaxColorType: SourceCodeTokenType) -> Color {
        switch syntaxColorType {
        case .plain:
            return .white

        case .number:
            return Color(red: 150/255, green: 134/255, blue: 245/255, alpha: 1.0)

        case .string:
            return Color(red: 252/255, green: 106/255, blue: 93/255, alpha: 1.0)

        case .identifier:
            return Color(red: 122/255, green: 200/255, blue: 182/255, alpha: 1.0)

        case .keyword:
            return Color(red: 252/255, green: 95/255, blue: 163/255, alpha: 1.0)

        case .comment:
            return Color(red: 108/255, green: 121/255, blue: 134/255, alpha: 1.0)

        case .editorPlaceholder:
            return backgroundColor
        }
    }
}
