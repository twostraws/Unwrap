//
//  PleaseSelectView.swift
//  Unwrap
//

import SwiftUI

struct PleaseSelectView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var logoProgress = 1.0

    let prompt: String

    var body: some View {
        VStack(spacing: 10) {
            Button {
                animateLogo()
            } label: {
                UnwrapLogoShape()
                    .trim(from: 0, to: logoProgress)
                    .stroke(.secondary, lineWidth: 2)
                    .frame(width: 250, height: 250)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Animate Unwrap logo")

            Text(prompt)
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 315)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func animateLogo() {
        guard reduceMotion == false else { return }

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            logoProgress = 0
        }

        withAnimation(.easeInOut(duration: 2)) {
            logoProgress = 1
        }
    }
}
