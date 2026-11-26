//
//  MultipleReviewView.swift
//  Unwrap
//

import SwiftUI

struct MultipleReviewView: View {
    @State private var scrollIndicatorFlash = false

    @Binding var session: ReviewSession
    let completedAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MarkdownText(markdown: session.content.question)
                .font(.headline)
                .promptCard()

            List {
                ForEach(session.candidates) { candidate in
                    MultipleReviewCandidateView(
                        candidate: candidate,
                        usesSyntaxHighlighting: session.content.syntaxHighlighting,
                        isSelected: session.isSelected(candidate),
                        isShowingAnswer: session.isShowingAnswer,
                        selectionAction: {
                            session.toggleSelection(for: candidate.id)
                        }
                    )
                }
            }
            .scrollIndicatorsFlash(trigger: scrollIndicatorFlash)
        }
        .background(Color(.systemGroupedBackground))
        .actionBar {
            PrimaryActionButton(
                title: session.isShowingAnswer ? "Continue" : "Check",
                action: actionButtonTapped
            )
        }
        .navigationTitle("Review")
        .onAppear {
            scrollIndicatorFlash.toggle()
        }
    }

    private func actionButtonTapped() {
        if session.isShowingAnswer {
            completedAction()
        } else {
            session.submitMultipleSelection()
        }
    }
}
