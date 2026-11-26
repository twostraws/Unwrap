//
//  PracticeSessionView.swift
//  Unwrap
//

import SwiftUI

struct PracticeSessionView: View {
    let session: PracticeSession
    let exitAction: () -> Void

    @State private var hint: String?
    @State private var errorMessage: String?
    @FocusState private var isCodeEditorFocused: Bool

    var body: some View {
        Group {
            if session.phase == .completed, let awardModel = session.awardModel {
                AwardView(model: awardModel, continueAction: exitAction)
            } else {
                PracticeQuestionView(
                    question: session.currentQuestion,
                    submitAction: session.submit,
                    continueAction: continueSession,
                    isCodeEditorFocused: $isCodeEditorFocused
                )
                .id(session.questionNumber)
            }
        }
        .navigationTitle(
            "\(session.kind.sessionTitle) (\(session.questionNumber)/\(PracticeSession.questionCount))"
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // Keep Skip and Hint within reach while a question scrolls.
        .toolbarMinimizationBehavior(.never, for: .navigationBar)
        .toolbar {
            if session.phase != .completed {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip", systemImage: "forward.end", action: exitAction)
                        .labelStyle(.titleAndIcon)
                        .disabled(canSkip == false)
                }

                ToolbarItem(placement: .primaryAction) {
                    if isCodeEditorFocused {
                        Button("Done") {
                            isCodeEditorFocused = false
                        }
                    } else {
                        Button("Hint", systemImage: "lightbulb") {
                            hint = session.requestHint()
                        }
                        .labelStyle(.titleAndIcon)
                        .disabled(session.canRequestHint == false)
                    }
                }
            }
        }
        .alert(
            "Hint",
            isPresented: Binding(
                get: { hint != nil },
                set: { isPresented in
                    if isPresented == false {
                        hint = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                hint = nil
            }
        } message: {
            MarkdownText(markdown: hint ?? "")
        }
        .alert(
            "Unable to Continue",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "The next question could not be loaded.")
        }
    }

    private var canSkip: Bool {
        session.phase == .answering
    }

    private func continueSession() {
        do {
            try session.continueSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
