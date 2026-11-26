//
//  ChallengeSessionView.swift
//  Unwrap
//

import SwiftUI

struct ChallengeSessionView: View {

    let model: ChallengesModel
    let session: ChallengeSession
    let question: PracticeQuestion
    let exitAction: () -> Void

    @State private var isHintPresented = false
    @State private var isSkipPresented = false
    @FocusState private var isCodeEditorFocused: Bool

    var body: some View {
        PracticeQuestionView(
            question: question,
            submitAction: model.submit,
            continueAction: model.finishQuestionFeedback,
            isCodeEditorFocused: $isCodeEditorFocused,
            allowsRetry: false
        )
        .id(session.questionNumber)
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Skip", systemImage: "forward.end") {
                    isSkipPresented = true
                }
                .labelStyle(.titleAndIcon)
                .disabled(session.phase != .answering)
            }

            ToolbarItem(placement: .primaryAction) {
                if isCodeEditorFocused {
                    Button("Done") {
                        isCodeEditorFocused = false
                    }
                } else {
                    Button("Hint", systemImage: "lightbulb") {
                        isHintPresented = true
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
        }
        .alert("Hint", isPresented: $isHintPresented) {
            Button("OK", role: .cancel) {
            }
        } message: {
            MarkdownText(markdown: question.hint)
        }
        .alert("Are you sure?", isPresented: $isSkipPresented) {
            if session.remainingSkips > 0 {
                Button("Skip Question") {
                    model.skipQuestion()
                }
            }

            Button("End Challenge", role: .destructive) {
                model.endChallenge()
                exitAction()
            }

            Button("Continue", role: .cancel) {
            }
        } message: {
            Text(
                "You can skip only three questions during a challenge, and if you quit you won't be able to take a daily challenge again until tomorrow.\n\nYou have \(session.remainingSkips.spelledOut) remaining."
            )
        }
    }
}
