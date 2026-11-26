//
//  LearnLessonRow.swift
//  Unwrap
//

import SwiftUI

struct LearnLessonRow: View {
    let title: String
    let progress: LessonProgress

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: "checkmark")
                .fontWeight(.bold)
                .frame(width: 25, height: 25)
                .foregroundStyle(iconColor)
                .opacity(progress == .unstarted ? 0 : 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconColor: Color {
        switch progress {
        case .unstarted:
            Color("CoursePartial")
        case .learned:
            Color("CoursePartial")
        case .reviewed:
            Color("CourseFull")
        }
    }

    private var accessibilityLabel: String {
        switch progress {
        case .unstarted:
            "\(title). Section not started"
        case .learned:
            "\(title). Section in progress"
        case .reviewed:
            "\(title). Section completed"
        }
    }
}
