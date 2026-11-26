//
//  FreeCodingSymbolKeypad.swift
//  Unwrap
//

import SwiftUI

struct FreeCodingSymbolKeypad: View {
    let insertAction: (Character) -> Void

    private let symbolRows = [
        Array("[]{}()<>:."),
        Array("=+-*!?,/$")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(symbolRows, id: \.self) { symbols in
                HStack(spacing: 0) {
                    ForEach(symbols, id: \.self) { symbol in
                        Button {
                            insertAction(symbol)
                        } label: {
                            Text(String(symbol))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .contentShape(.rect)
                        }
                        .accessibilityLabel("Insert \(String(symbol))")
                    }
                }
            }
        }
        .font(.title2.monospacedDigit())
        .foregroundStyle(.primary)
        .buttonStyle(.plain)
        .background(.regularMaterial)
    }
}
