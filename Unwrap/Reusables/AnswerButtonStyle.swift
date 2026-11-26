//
//  AnswerButtonStyle.swift
//  Unwrap
//

import SwiftUI

/// Keeps submitted answers readable while their buttons remain disabled.
struct AnswerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled && configuration.isPressed ? 0.65 : 1)
    }
}

extension ButtonStyle where Self == AnswerButtonStyle {
    static var answer: AnswerButtonStyle {
        AnswerButtonStyle()
    }
}
