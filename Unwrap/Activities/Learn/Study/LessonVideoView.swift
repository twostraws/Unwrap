//
//  LessonVideoView.swift
//  Unwrap
//

import AVKit
import SwiftUI

struct LessonVideoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer

    init(url: URL) {
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            Button("Done") {
                // Turn back to portrait as we leave, rather than showing the lesson sideways first.
                InterfaceOrientationLock.setAllowsLandscape(false)
                dismiss()
            }
            .foregroundStyle(.white)
            .padding()
            .safeAreaPadding(.top)
        }
        .allowsLandscape()
        .task {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
    }
}
