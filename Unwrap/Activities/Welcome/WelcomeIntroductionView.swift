//
//  WelcomeIntroductionView.swift
//  Unwrap
//

import SwiftUI

struct WelcomeIntroductionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var welcomeFontSize = 36
    @ScaledMetric(relativeTo: .largeTitle) private var startTourFontSize = 36
    @ScaledMetric(relativeTo: .title) private var closeFontSize = 26
    @State private var logoOpacity = 0.0
    @State private var welcomeOpacity = 0.0
    @State private var startTourOpacity = 0.0
    @State private var closeOpacity = 0.0

    let startTour: () -> Void
    let close: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AnimatedUnwrapLogoView()
                    .frame(width: 250, height: 250)
                    .offset(x: -5)
                    .opacity(logoOpacity)
                    .accessibilityHidden(true)
                    .padding(.top, 30)

                Text("Welcome to Unwrap")
                    .font(.system(size: welcomeFontSize, weight: .light))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(welcomeOpacity)

                Button("Start Tour", action: startTour)
                    .font(.system(size: startTourFontSize))
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, minHeight: 55)
                    .padding(.top, 40)
                    .opacity(startTourOpacity)

                Button("Close", action: close)
                    .font(.system(size: closeFontSize))
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .opacity(closeOpacity)
            }
            .containerRelativeFrame(.vertical)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(.white)
        .task {
            if reduceMotion {
                logoOpacity = 1
                welcomeOpacity = 1
                startTourOpacity = 1
                closeOpacity = 1
            } else {
                withAnimation(.easeInOut(duration: 2.5)) {
                    logoOpacity = 1
                }

                withAnimation(.easeInOut(duration: 1.5).delay(1)) {
                    welcomeOpacity = 1
                }

                withAnimation(.easeInOut(duration: 1).delay(1.5)) {
                    startTourOpacity = 1
                }

                withAnimation(.easeInOut(duration: 0.5).delay(2)) {
                    closeOpacity = 1
                }
            }
        }
    }
}
