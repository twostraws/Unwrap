//
//  SpotErrorQuestionView.swift
//  Unwrap
//

import SwiftUI

struct SpotErrorQuestionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: SpotErrorQuestionState
    @State private var isTipPresented = false

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: SpotErrorQuestionState,
        submitAction: @escaping (PracticeAnswerResult) -> Bool,
        continueAction: @escaping () -> Void
    ) {
        _state = State(initialValue: state)
        self.submitAction = submitAction
        self.continueAction = continueAction
    }

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                PracticePromptText(markdown: state.prompt)

                VStack(spacing: 0) {
                    ForEach(state.lines) { line in
                        Button {
                            state.select(lineID: line.id)
                        } label: {
                            Text(
                                SwiftCodeHighlighter().attributedString(
                                    for: line.text,
                                    colorScheme: colorScheme,
                                    foregroundColor: foregroundColor(for: line)
                                )
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.answer)
                        .disabled(state.isLocked)
                        .id(line.id)
                        .accessibilityLabel("Line \(line.id + 1): \(line.text)")
                        .accessibilityValue(accessibilityValue(for: line))
                        .answerRow(
                            background: backgroundColor(for: line),
                            isLast: line.id == state.lines.last?.id
                        )
                    }
                }
                .answerCard()
            }
            .background(Color(.systemGroupedBackground))
            .actionBar {
                PrimaryActionButton(
                    title: primaryTitle,
                    systemImage: state.outcome.map { $0 == .correct ? "checkmark" : "xmark" },
                    color: primaryBackground,
                    action: primaryAction
                )
                .disabled(state.isLocked == false && state.isReadyToSubmit == false)
            }
            .onChange(of: state.scrollTargetID) { _, targetID in
                if let targetID {
                    if reduceMotion {
                        proxy.scrollTo(targetID, anchor: .center)
                    } else {
                        withAnimation(.smooth) {
                            proxy.scrollTo(targetID, anchor: .center)
                        }
                    }
                }
            }
        }
        .task {
            isTipPresented = PracticeTip.spotTheError.claimPresentation()
        }
        .alert(PracticeTip.spotTheError.title, isPresented: $isTipPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(PracticeTip.spotTheError.message)
        }
    }

    private var primaryTitle: String {
        if state.isLocked {
            "Continue"
        } else if let selectedLineID = state.selectedLineID {
            "Error on Line \(selectedLineID + 1)"
        } else {
            "Select a Line"
        }
    }

    private func primaryAction() {
        if state.isLocked {
            continueAction()
        } else if let result = state.submit() {
            _ = submitAction(result)
        }
    }

    private func backgroundColor(for line: SpotErrorQuestionState.Line) -> Color? {
        switch state.result(for: line) {
        case .correct:
            Color("ReviewCorrect")
        case .incorrect:
            Color("ReviewWrong")
        case .selected:
            .accentColor.opacity(0.15)
        case .unanswered:
            nil
        }
    }

    private func foregroundColor(for line: SpotErrorQuestionState.Line) -> Color? {
        switch state.result(for: line) {
        case .correct, .incorrect:
            .white
        case .selected, .unanswered:
            nil
        }
    }

    private func accessibilityValue(for line: SpotErrorQuestionState.Line) -> String {
        switch state.result(for: line) {
        case .correct:
            "Correct error line"
        case .incorrect:
            line.id == state.errorLineID ? "Missed error line" : "Incorrect selection"
        case .selected:
            "Selected"
        case .unanswered:
            "Not selected"
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
