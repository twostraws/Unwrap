//
//  ReviewQuestionView.swift
//  Unwrap
//

import SwiftUI

struct ReviewQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: ReviewQuestionState

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: ReviewQuestionState,
        submitAction: @escaping (PracticeAnswerResult) -> Bool,
        continueAction: @escaping () -> Void
    ) {
        _state = State(initialValue: state)
        self.submitAction = submitAction
        self.continueAction = continueAction
    }

    var body: some View {
        VStack(spacing: 0) {
            PracticePromptText(
                markdown: state.prompt,
                explanation: state.style == .single && state.isLocked
                    ? state.choices.first?.reason
                    : nil
            )

            switch state.style {
            case .single:
                if let choice = state.choices.first {
                    ScrollView {
                        if state.usesSyntaxHighlighting {
                            Text(
                                SwiftCodeHighlighter().attributedString(
                                    for: choice.text,
                                    colorScheme: colorScheme
                                )
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .textSelection(.enabled)
                        } else {
                            MarkdownText(markdown: choice.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            case .multiple:
                VStack(spacing: 0) {
                    ForEach(state.choices) { choice in
                        Button {
                            state.toggleChoice(id: choice.id)
                        } label: {
                            HStack(alignment: .top) {
                                Image(
                                    systemName: state.selectedChoiceIDs.contains(choice.id)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .foregroundStyle(selectionColor(for: choice))
                                .accessibilityHidden(true)

                                VStack(alignment: .leading) {
                                    if state.usesSyntaxHighlighting {
                                        Text(
                                            SwiftCodeHighlighter().attributedString(
                                                for: choice.text,
                                                colorScheme: colorScheme,
                                                foregroundColor: state.result(for: choice) == .unanswered ? nil : .white
                                            )
                                        )
                                    } else {
                                        MarkdownText(markdown: choice.text)
                                    }

                                    if state.isLocked, choice.reason.isEmpty == false {
                                        MarkdownText(markdown: choice.reason)
                                            .font(.caption)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(foregroundColor(for: choice))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.answer)
                        .disabled(state.isLocked)
                        .accessibilityValue(state.accessibilityValue(for: choice))
                        .answerRow(
                            background: backgroundColor(for: choice),
                            isLast: choice.id == state.choices.last?.id
                        )
                    }
                }
                .answerCard()
            }
        }
        .background(Color(.systemGroupedBackground))
        .actionBar {
            switch state.style {
            case .single:
                ForEach([true, false], id: \.self) { value in
                    let isSelected = state.selectedTruth == value

                    PrimaryActionButton(
                        title: isSelected && state.isLocked ? "Continue" : value ? "True" : "False",
                        systemImage: isSelected ? state.outcome.map { $0 == .correct ? "checkmark" : "xmark" } : nil,
                        color: truthButtonBackground(value: value)
                    ) {
                        truthTapped(value)
                    }
                    .disabled(state.isLocked && isSelected == false)
                    .accessibilityValue(isSelected ? "Selected" : "Not selected")
                }

            case .multiple:
                PrimaryActionButton(
                    title: state.isLocked ? "Continue" : "Check",
                    action: multipleChoicePrimaryAction
                )
            }
        }
    }

    private func truthTapped(_ value: Bool) {
        if state.isLocked {
            continueAction()
        } else {
            state.selectTruth(value)

            if let result = state.submit() {
                _ = submitAction(result)
            }
        }
    }

    private func multipleChoicePrimaryAction() {
        if state.isLocked {
            continueAction()
        } else if let result = state.submit() {
            _ = submitAction(result)
        }
    }

    private func truthButtonBackground(value: Bool) -> Color {
        guard state.isLocked else {
            return value ? Color("BrandPrimary") : Color("BrandSecondary")
        }

        guard state.selectedTruth == value else {
            return Color("Disabled")
        }

        return state.outcome == .correct ? Color("ReviewCorrect") : Color("ReviewWrong")
    }

    private func backgroundColor(for choice: ReviewQuestionState.Choice) -> Color? {
        switch state.result(for: choice) {
        case .correct:
            Color("ReviewCorrect")
        case .incorrect, .missed:
            Color("ReviewWrong")
        case .unanswered:
            state.selectedChoiceIDs.contains(choice.id) ? .accentColor.opacity(0.15) : nil
        }
    }

    private func foregroundColor(for choice: ReviewQuestionState.Choice) -> Color {
        switch state.result(for: choice) {
        case .correct, .incorrect, .missed:
            .white
        case .unanswered:
            .primary
        }
    }

    private func selectionColor(for choice: ReviewQuestionState.Choice) -> Color {
        switch state.result(for: choice) {
        case .correct, .incorrect, .missed:
            .white.opacity(0.5)
        case .unanswered:
            state.selectedChoiceIDs.contains(choice.id) ? .accentColor : .secondary
        }
    }
}
