//
//  LightTheme.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Sourceful
import UIKit

/// A source code theme that has a light background and dark text. This is the default.
public struct LightTheme: SourceCodeTheme {
    public var lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Unwrap.codeFont, textColor: Color.darkGray)
    public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color(white: 0.95, alpha: 1), minimumWidth: 32)

    public let backgroundColor = Color.white
    public let font = Unwrap.codeFont

    public func globalAttributes() -> [NSAttributedString.Key: Any] {
        return [.font: Unwrap.codeFont, .foregroundColor: UIColor.black]
    }

    public func color(for syntaxColorType: SourceCodeTokenType) -> Color {
        switch syntaxColorType {
        case .plain:
            return .black

        case .number:
            return Color(red: 28/255, green: 0/255, blue: 207/255, alpha: 1.0)

        case .string:
            return Color(red: 196/255, green: 26/255, blue: 22/255, alpha: 1.0)

        case .identifier:
            return Color(red: 63/255, green: 110/255, blue: 116/255, alpha: 1.0)

        case .keyword:
            return Color(red: 170/255, green: 13/255, blue: 145/255, alpha: 1.0)

        case .comment:
            return Color(red: 0, green: 116/255, blue: 0, alpha: 1.0)

        case .editorPlaceholder:
            return backgroundColor
        }
    }
}
