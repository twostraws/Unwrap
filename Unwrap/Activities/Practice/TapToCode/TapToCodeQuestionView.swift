//
//  TapToCodeQuestionView.swift
//  Unwrap
//

import SwiftUI

struct TapToCodeQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: TapToCodeQuestionState

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void

    init(
        state: TapToCodeQuestionState,
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

            if state.existingCode.isEmpty == false {
                Text(
                    SwiftCodeHighlighter().attributedString(
                        for: state.existingCode,
                        colorScheme: colorScheme
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .accessibilityLabel("Existing Swift code")
                .accessibilityValue(state.existingCode)
            }

            VStack(spacing: 0) {
                ScrollView {
                    PracticeTokenFlowLayout(spacing: 10) {
                        ForEach(state.usedTokens) { token in
                            TapToCodeUsedTokenButton(
                                token: token,
                                outcome: state.outcome,
                                tapAction: { state.tap(tokenID: token.id) }
                            )
                        }
                        .reorderable(collectionID: TapToCodeArea.used)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                }
                .background(.quaternary)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 0.5)
                }
                .overlay {
                    if state.usedTokens.isEmpty {
                        Text("Tap code to add it here.")
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxHeight: .infinity)

                ScrollView {
                    PracticeTokenFlowLayout(spacing: 10) {
                        ForEach(state.availableTokens) { token in
                            TapToCodeAvailableTokenButton(
                                token: token,
                                tapAction: { state.tap(tokenID: token.id) }
                            )
                        }
                        .reorderable(collectionID: TapToCodeArea.available)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            // One container spans both areas, so a token can be dragged between them as well as within them.
            .reorderContainer(
                for: TapToCodeToken.self,
                in: TapToCodeArea.self,
                isEnabled: state.isLocked == false
            ) { difference in
                withAnimation {
                    move(difference)
                }
            }
        }
        .actionBar {
            // There is nothing to submit until every piece of code has been used.
            if state.isReadyToSubmit {
                PrimaryActionButton(
                    title: "Submit",
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
        } else if let result = state.submit() {
            _ = submitAction(result)
        }
    }

    private func move(_ difference: ReorderDifference<Int, TapToCodeArea>) {
        let targetID: Int? = switch difference.destination.position {
        case .before(let tokenID): tokenID
        case .end: nil
        }

        state.moveTokens(withIDs: difference.sources, to: difference.destination.collectionID, before: targetID)
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
