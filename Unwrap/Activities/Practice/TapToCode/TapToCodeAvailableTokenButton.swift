//
//  TapToCodeAvailableTokenButton.swift
//  Unwrap
//

import SwiftUI

struct TapToCodeAvailableTokenButton: View {
    let token: TapToCodeToken
    let tapAction: () -> Void

    var body: some View {
        Button(action: tapAction) {
            Text(token.text)
                .font(.body)
                .foregroundStyle(.black)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color(white: 0.95))
                .clipShape(.rect(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Moves this component to your code")
    }
}
