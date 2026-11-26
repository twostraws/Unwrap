//
//  PracticeAnswerInputModifier.swift
//  Unwrap
//

import SwiftUI

struct PracticeAnswerInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.asciiCapable)
    }
}
