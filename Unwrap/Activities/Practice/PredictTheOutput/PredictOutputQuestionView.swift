//
//  PredictOutputQuestionView.swift
//  Unwrap
//

import SwiftUI

struct PredictOutputQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: PredictOutputQuestionState
    @FocusState private var isAnswerFocused: Bool

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: PredictOutputQuestionState,
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
                explanation: state.outcome == .incorrect
                    ? "This code will print \"\(state.normalizedCorrectOutput)\"."
                    : nil
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(
                        SwiftCodeHighlighter().attributedString(
                            for: state.code,
                            colorScheme: colorScheme
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .accessibilityLabel("Swift code")
                    .accessibilityValue(state.code)

                    TextField(
                        "Type your answer here",
                        text: Binding(
                            get: { state.answer },
                            set: { state.updateAnswer($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .practiceAnswerInput()
                    .submitLabel(.done)
                    .focused($isAnswerFocused)
                    .onSubmit {
                        if state.isLocked == false {
                            submit()
                        }
                    }
                }
                .padding(20)
            }
        }
        .actionBar {
            if isAnswerFocused || state.isLocked {
                PrimaryActionButton(
                    title: state.isLocked ? "Continue" : "Submit",
                    systemImage: state.outcome.map { $0 == .correct ? "checkmark" : "xmark" },
                    color: primaryBackground,
                    action: primaryAction
                )
            }
        }
    }

    private func primaryAction() {
        if state.isLocked {
            continueAction()
        } else {
            submit()
        }
    }

    private func submit() {
        if let result = state.submit() {
            _ = submitAction(result)
        }
    }

    private var primaryBackground: Color {
        switch state.outcome {
        case .correct:
            Color("ReviewCorrect")
        case .incorrect, .retryableIncorrect:
            Color("ReviewWrong")
        case nil:
            Color("BrandPrimary")
        }
    }
}
