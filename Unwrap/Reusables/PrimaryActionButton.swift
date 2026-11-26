//
//  PrimaryActionButton.swift
//  Unwrap
//

import SwiftUI

/// The prominent button used to submit an answer or move on to the next question.
struct PrimaryActionButton: View {
    let title: String

    /// An optional SF Symbol to show before the title, such as a check mark once an answer is marked.
    var systemImage: String?

    var color = Color("BrandPrimary")
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .font(.title3)
            .bold()
            .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.glassProminent)
        .tint(color)
    }
}

extension View {
    /// Places one or more action buttons at the bottom of the screen, inside the safe area, so that scrolling
    /// content passes beneath them. Buttons sit side by side, or stack when text is very large.
    func actionBar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        safeAreaBar(edge: .bottom, spacing: 0) {
            ActionBar(content: content)
        }
        .scrollEdgeEffectStyle(.hard, for: .bottom)
    }
}

private struct ActionBar<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ViewBuilder let content: Content

    var body: some View {
        Group(subviews: content) { buttons in
            if buttons.isEmpty == false {
                layout {
                    buttons
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
    }

    private var layout: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            AnyLayout(VStackLayout(spacing: 10))
        } else {
            AnyLayout(HStackLayout(spacing: 12))
        }
    }
}
