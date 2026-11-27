//
//  LearnDestinationView.swift
//  Unwrap
//

import SwiftUI

struct LearnDestinationView: View {
    let user: User
    @Binding var selection: LearnRoute?
    let lesson: Lesson?

    var body: some View {
        Group {
            if let selection {
                switch selection {
                case .workshop:
                    BadgeWorkshopView()
                case .glossary:
                    GlossaryView(index: Self.glossaryIndex)
                case .study(let title):
                    if lesson?.title == title, let lesson {
                        LearnStudyFlowView(
                            lesson: lesson,
                            user: user,
                            openBrowser: showBrowser,
                            onFinished: clearSelection
                        )
                        .id(title)
                    } else {
                        ContentUnavailableView(
                            "Lesson Unavailable",
                            systemImage: "exclamationmark.triangle"
                        )
                    }
                case .browser(let url):
                    BrowserView(url: url)
                }
            } else {
                PleaseSelectView(prompt: "Please select a topic to learn")
            }
        }
    }

    private static let glossaryIndex: GlossaryIndex = {
        do {
            let entries = try Bundle.main.decode(
                [LearnGlossaryEntry].self,
                from: "glossary.json"
            )
            return GlossaryIndex(entries: entries)
        } catch {
            preconditionFailure("Unable to load glossary.json: \(error)")
        }
    }()

    private func clearSelection() {
        selection = nil
    }

    private func showBrowser(_ url: URL) {
        selection = .browser(url)
    }
}
