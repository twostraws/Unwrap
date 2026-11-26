//
//  ReviewSessionView.swift
//  Unwrap
//

import SwiftUI

struct ReviewSessionView: View {
    @State private var showsHint = false

    @Binding var session: ReviewSession
    let completedAction: () -> Void
    let skippedAction: () -> Void

    var body: some View {
        Group {
            switch session.content.kind {
            case .singleSelection:
                SingleReviewView(
                    session: $session,
                    completedAction: completedAction
                )
            case .multipleSelection:
                MultipleReviewView(
                    session: $session,
                    completedAction: completedAction
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Skip", systemImage: "forward.end") {
                    skippedAction()
                }
                .labelStyle(.titleAndIcon)
                .disabled(session.canSkip == false)
            }

            ToolbarItem(placement: .primaryAction) {
                Button("Hint", systemImage: "lightbulb") {
                    showsHint = true
                }
                .labelStyle(.titleAndIcon)
            }
        }
        .alert("Hint", isPresented: $showsHint) {
            Button("Continue", role: .cancel) { }
        } message: {
            MarkdownText(markdown: session.content.hint)
        }
    }
}
