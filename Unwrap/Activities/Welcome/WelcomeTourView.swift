//
//  WelcomeTourView.swift
//  Unwrap
//

import SwiftUI

struct WelcomeTourView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingPages = false

    let items: [TourItem]
    let closeAction: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("UnwrapGradientTop"), Color("UnwrapGradientBottom")],
                startPoint: .top,
                endPoint: .bottom
            )

            if isShowingPages {
                TourPagesView(items: items, close: closeAction)
                    .transition(.opacity)
            } else {
                WelcomeIntroductionView(
                    startTour: {
                        showTourPages()
                    },
                    close: closeAction
                )
                .transition(.opacity)
            }
        }
        .tint(.white)
        .accessibilityAction(.escape, closeAction)
    }

    private func showTourPages() {
        if reduceMotion {
            isShowingPages = true
        } else {
            withAnimation(.easeInOut(duration: 0.5)) {
                isShowingPages = true
            }
        }
    }
}
