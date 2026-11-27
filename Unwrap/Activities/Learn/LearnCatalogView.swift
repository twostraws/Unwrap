//
//  LearnCatalogView.swift
//  Unwrap
//

import SwiftUI

struct LearnCatalogView: View {
    let chapters: [Chapter]
    let user: User
    @Binding var selection: LearnRoute?

    var body: some View {
        List(selection: $selection) {
            Section("Build an app") {
                NavigationLink("Badge workshop", value: LearnRoute.workshop)
            }
            ForEach(chapters, id: \.name) { chapter in
                Section(chapter.name) {
                    ForEach(chapter.sections, id: \.self) { title in
                        let progress = LessonProgress(
                            hasLearned: user.hasLearned(title.bundleName),
                            hasReviewed: user.hasReviewed(title.bundleName)
                        )

                        NavigationLink(value: LearnRoute.study(title)) {
                            LearnLessonRow(title: title, progress: progress)
                        }
                        .contextMenu {
                            EmptyView()
                        } preview: {
                            LearnLessonPreviewView(title: title)
                        }
                    }
                }
            }
        }
        .navigationTitle("Learn")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Glossary") {
                    selection = .glossary
                }
            }
        }
    }
}
