//
//  LearnView.swift
//  Unwrap
//

import SwiftUI

struct LearnView: View {
    @Environment(User.self) private var user
    @State private var selection: LearnRoute?
    @State private var selectedLesson: Lesson?

    var body: some View {
        NavigationSplitView {
            LearnCatalogView(
                chapters: Unwrap.chapters,
                user: user,
                selection: routedSelection
            )
        } detail: {
            LearnDestinationView(
                user: user,
                selection: routedSelection,
                lesson: selectedLesson
            )
        }
    }

    private var routedSelection: Binding<LearnRoute?> {
        Binding(
            get: { selection },
            set: { route in
                if let route, case .study(let title) = route {
                    selectedLesson = try? Lesson(title: title)
                } else {
                    selectedLesson = nil
                }

                selection = route
            }
        )
    }
}
