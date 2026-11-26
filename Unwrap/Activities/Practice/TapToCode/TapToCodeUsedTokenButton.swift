//
//  TapToCodeUsedTokenButton.swift
//  Unwrap
//

import SwiftUI

struct TapToCodeUsedTokenButton: View {
    let token: TapToCodeToken
    let outcome: PracticeAnswerResult?
    let tapAction: () -> Void

    var body: some View {
        if let outcome {
            Text(token.text)
                .font(.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(
                    outcome == .correct ? Color("ReviewCorrect") : Color("ReviewWrong")
                )
                .clipShape(.rect(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                .accessibilityValue(outcome == .correct ? "Correct position" : "Incorrect position")
        } else {
            Button(action: tapAction) {
                Text(token.text)
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Moves this component back to available code")
        }
    }
}
