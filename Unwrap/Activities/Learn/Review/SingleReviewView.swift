//
//  SingleReviewView.swift
//  Unwrap
//

import SwiftUI

struct SingleReviewView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var session: ReviewSession
    let completedAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                MarkdownText(markdown: session.content.question)
                    .font(.headline)

                if session.isShowingAnswer,
                   let reason = session.currentCandidate?.answer.reason,
                   reason.isEmpty == false {
                    MarkdownText(markdown: reason)
                        .font(.body)
                        .bold()
                }
            }
            .promptCard()

            ScrollView {
                if let candidate = session.currentCandidate {
                    Text(
                        SwiftCodeHighlighter().attributedString(
                            for: candidate.answer.text,
                            colorScheme: colorScheme
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                    .textSelection(.enabled)
                    .accessibilityLabel("Swift code")
                    .accessibilityValue(candidate.answer.text)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(colorScheme == .dark ? Color.black : Color.white, ignoresSafeAreaEdges: [])
            .id(session.currentCandidate?.id)
        }
        .actionBar {
            PrimaryActionButton(
                title: session.selectedTruth == true && session.isShowingAnswer ? "Continue" : "True",
                systemImage: session.selectedTruth == true && session.isShowingAnswer ? answerImageName : nil,
                color: trueButtonColor,
                action: trueTapped
            )
            .disabled(session.isShowingAnswer && session.selectedTruth != true)

            PrimaryActionButton(
                title: session.selectedTruth == false && session.isShowingAnswer ? "Continue" : "False",
                systemImage: session.selectedTruth == false && session.isShowingAnswer ? answerImageName : nil,
                color: falseButtonColor,
                action: falseTapped
            )
            .disabled(session.isShowingAnswer && session.selectedTruth != false)
        }
        .navigationTitle("Review (\(session.questionNumber)/\(ReviewSession.singleQuestionCount))")
    }

    private var answerImageName: String {
        session.submittedAnswerWasCorrect == true ? "checkmark" : "xmark"
    }

    private var trueButtonColor: Color {
        guard session.isShowingAnswer else { return Color("BrandPrimary") }
        guard session.selectedTruth == true else { return Color("Disabled") }
        return session.submittedAnswerWasCorrect == true ? Color("ReviewCorrect") : Color("ReviewWrong")
    }

    private var falseButtonColor: Color {
        guard session.isShowingAnswer else { return Color("BrandSecondary") }
        guard session.selectedTruth == false else { return Color("Disabled") }
        return session.submittedAnswerWasCorrect == true ? Color("ReviewCorrect") : Color("ReviewWrong")
    }

    private func trueTapped() {
        if session.selectedTruth == true, session.isShowingAnswer {
            advance()
        } else {
            session.answerCurrent(true)
        }
    }

    private func falseTapped() {
        if session.selectedTruth == false, session.isShowingAnswer {
            advance()
        } else {
            session.answerCurrent(false)
        }
    }

    private func advance() {
        if session.advance() {
            completedAction()
        }
    }
}
