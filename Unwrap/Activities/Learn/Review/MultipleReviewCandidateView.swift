//
//  MultipleReviewCandidateView.swift
//  Unwrap
//

import SwiftUI

struct MultipleReviewCandidateView: View {
    @Environment(\.colorScheme) private var colorScheme

    let candidate: ReviewCandidate
    let usesSyntaxHighlighting: Bool
    let isSelected: Bool
    let isShowingAnswer: Bool
    let selectionAction: () -> Void

    var body: some View {
        Button(action: selectionAction) {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectionIndicatorColor)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    if usesSyntaxHighlighting {
                        Text(
                            SwiftCodeHighlighter().attributedString(
                                for: candidate.answer.text,
                                colorScheme: colorScheme,
                                foregroundColor: isShowingAnswer && (candidate.isCorrect || isSelected) ? .white : nil
                            )
                        )
                    } else {
                        MarkdownText(markdown: candidate.answer.text)
                    }

                    if isShowingAnswer {
                        MarkdownText(markdown: candidate.answer.reason)
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(foregroundColor)
            .contentShape(.rect)
        }
        .buttonStyle(.answer)
        .disabled(isShowingAnswer)
        .listRowBackground(backgroundColor)
        .accessibilityElement(children: .combine)
        .accessibilityValue(accessibilityValue)
    }

    private var backgroundColor: Color? {
        guard isShowingAnswer else {
            return isSelected ? Color.accentColor.opacity(0.12) : nil
        }

        if candidate.isCorrect {
            return isSelected ? Color("ReviewCorrect") : Color("ReviewWrong")
        } else {
            return isSelected ? Color("ReviewWrong") : nil
        }
    }

    private var foregroundColor: Color {
        isShowingAnswer && (candidate.isCorrect || isSelected) ? .white : .primary
    }

    private var selectionIndicatorColor: Color {
        isShowingAnswer && (candidate.isCorrect || isSelected) ? .white.opacity(0.35) : .accentColor
    }

    private var accessibilityValue: String {
        guard isShowingAnswer else { return isSelected ? "Selected" : "Not selected" }

        if isSelected {
            return candidate.isCorrect ? "Selected, correct" : "Selected, incorrect"
        } else {
            return candidate.isCorrect ? "Not selected, missed correct answer" : "Not selected"
        }
    }
}
