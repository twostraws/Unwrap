//
//  LessonStudyView.swift
//  Unwrap
//

import SwiftUI

struct LessonStudyView: View {
    @Environment(\.openURL) private var systemOpenURL
    @State private var isVideoPresented = false

    let lesson: Lesson
    let openBrowser: @MainActor @Sendable (URL) -> Void
    let continueAction: () -> Void

    var body: some View {
        LessonContentView(
            lesson: lesson,
            content: lesson.content,
            playVideo: playVideo
        )
        .environment(\.openURL, OpenURLAction(handler: openLessonURL))
        .navigationTitle(lesson.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Next", action: continueAction)
            }
        }
        .fullScreenCover(isPresented: $isVideoPresented) {
            if let videoURL = lesson.videoURL {
                LessonVideoView(url: videoURL)
            }
        }
    }

    private func playVideo() {
        guard lesson.videoURL != nil else { return }
        isVideoPresented = true
    }

    private func openLessonURL(_ url: URL) -> OpenURLAction.Result {
        if url.scheme?.lowercased() == "mailto" {
            systemOpenURL(url)
        } else {
            openBrowser(url)
        }

        return .handled
    }
}
