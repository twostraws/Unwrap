//
//  RearrangeQuestionView.swift
//  Unwrap
//

import SwiftUI

struct RearrangeQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: RearrangeQuestionState
    @State private var contentHeight: CGFloat?

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: RearrangeQuestionState,
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

            List {
                Section {
                    ForEach(state.lines.enumerated(), id: \.element.id) { index, line in
                        HStack(spacing: 12) {
                            Text(
                                SwiftCodeHighlighter().attributedString(
                                    for: line.text,
                                    colorScheme: colorScheme,
                                    foregroundColor: state.isLocked ? .white : nil
                                )
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                            if state.isLocked == false {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(.tertiary)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Line \(index + 1): \(line.text)")
                        .accessibilityValue(resultAccessibilityValue(for: line))
                        .listRowInsets(EdgeInsets(top: 11, leading: 20, bottom: 11, trailing: 20))
                        .listRowBackground(backgroundColor(for: line) ?? Color(.secondarySystemGroupedBackground))
                    }
                    .onMove { fromOffsets, toOffset in
                        state.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .moveDisabled(state.isLocked)
                }
                .listSectionSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height
            } action: { _, height in
                // An empty measurement would collapse the list, leaving it nothing to measure afterwards.
                if height > 0 {
                    contentHeight = height
                }
            }
            // Shaping the list itself, rather than its rows, keeps the card's corners in place while rows move.
            .frame(maxHeight: contentHeight)
            .clipShape(.rect(cornerRadius: 20))
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color(.systemGroupedBackground))
        .actionBar {
            PrimaryActionButton(
                title: state.isLocked ? "Continue" : "Submit",
                systemImage: state.outcome.map { $0 == .correct ? "checkmark" : "xmark" },
                color: primaryBackground,
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

    private func backgroundColor(for line: RearrangeQuestionState.Line) -> Color? {
        switch state.result(for: line) {
        case .correct:
            Color("ReviewCorrect")
        case .incorrect:
            Color("ReviewWrong")
        case .unanswered:
            nil
        }
    }

    private func resultAccessibilityValue(for line: RearrangeQuestionState.Line) -> String {
        switch state.result(for: line) {
        case .correct:
            "Correct position"
        case .incorrect:
            "Incorrect position"
        case .unanswered:
            "Not evaluated"
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
