//
//  LearnLessonPreviewView.swift
//  Unwrap
//

import SwiftUI

struct LearnLessonPreviewView: View {
    private let lesson: Lesson?

    init(title: String) {
        lesson = try? Lesson(title: title)
    }

    var body: some View {
        if let lesson {
            LessonContentView(
                lesson: lesson,
                content: lesson.content,
                playVideo: { }
            )
        } else {
            ContentUnavailableView("Lesson Unavailable", systemImage: "exclamationmark.triangle")
        }
    }
}
