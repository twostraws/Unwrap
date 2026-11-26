//
//  AnimatedUnwrapLogoView.swift
//  Unwrap
//

import SwiftUI

struct AnimatedUnwrapLogoView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0

    var body: some View {
        UnwrapLogoShape()
            .trim(from: 0, to: progress)
            .stroke(.white, lineWidth: 3)
            .task {
                if reduceMotion {
                    progress = 1
                } else {
                    try? await Task.sleep(for: .seconds(0.5))
                    guard Task.isCancelled == false else { return }

                    withAnimation(.easeInOut(duration: 2)) {
                        progress = 1
                    }
                }
            }
    }
}
