//
//  TypeCheckerQuestionView.swift
//  Unwrap
//

import SwiftUI

struct TypeCheckerQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: TypeCheckerQuestionState

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: TypeCheckerQuestionState,
        submitAction: @escaping (PracticeAnswerResult) -> Bool,
        continueAction: @escaping () -> Void
    ) {
        _state = State(initialValue: state)
        self.submitAction = submitAction
        self.continueAction = continueAction
    }

    var body: some View {
        VStack(spacing: 0) {
            PracticePromptText(markdown: state.prompt)

            VStack(spacing: 0) {
                ForEach(state.choices) { choice in
                    Button {
                        state.toggleChoice(id: choice.id)
                    } label: {
                        HStack {
                            Image(
                                systemName: state.selectedChoiceIDs.contains(choice.id)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundStyle(selectionColor(for: choice))
                            .accessibilityHidden(true)

                            Text(
                                SwiftCodeHighlighter().attributedString(
                                    for: choice.code,
                                    colorScheme: colorScheme,
                                    foregroundColor: state.result(for: choice) == .unanswered ? nil : .white
                                )
                            )
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
        .background(Color(.systemGroupedBackground))
        .actionBar {
            PrimaryActionButton(
                title: state.isLocked ? "Continue" : "Check",
                action: primaryAction
            )
        }
    }

    private func primaryAction() {
        if state.isLocked {
            continueAction()
        } else if let result = state.submit() {
            _ = submitAction(result)
        }
    }

    private func backgroundColor(for choice: TypeCheckerQuestionState.Choice) -> Color? {
        switch state.result(for: choice) {
        case .correct:
            Color("ReviewCorrect")
        case .incorrect, .missed:
            Color("ReviewWrong")
        case .unanswered:
            state.selectedChoiceIDs.contains(choice.id) ? .accentColor.opacity(0.15) : nil
        }
    }

    private func foregroundColor(for choice: TypeCheckerQuestionState.Choice) -> Color {
        switch state.result(for: choice) {
        case .correct, .incorrect, .missed:
            .white
        case .unanswered:
            .primary
        }
    }

    private func selectionColor(for choice: TypeCheckerQuestionState.Choice) -> Color {
        switch state.result(for: choice) {
        case .correct, .incorrect, .missed:
            .white.opacity(0.5)
        case .unanswered:
            state.selectedChoiceIDs.contains(choice.id) ? .accentColor : .secondary
        }
    }
}
