//
//  View-TourPresentation.swift
//  Unwrap
//

import SwiftUI

extension View {
    @ViewBuilder
    func tourPresentation<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Button {
                        isPresented.wrappedValue = false
                    } label: {
                        Color("AlertBackgroundDim")
                            .ignoresSafeArea()
                    }
                    .buttonStyle(.plain)
                    .accessibilityHidden(true)

                    content()
                        .containerRelativeFrame(.horizontal) { availableWidth, _ in
                            min(availableWidth * 0.9, 400)
                        }
                        .aspectRatio(375 / 667, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.3), radius: 10)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented.wrappedValue)
    }
}
