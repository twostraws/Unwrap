//
//  FreeCodingQuestionView.swift
//  Unwrap
//

import SwiftUI

struct FreeCodingQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: FreeCodingQuestionState
    @State private var isTipPresented = false
    @State private var isIncorrectAlertPresented = false

    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void
    let allowsRetry: Bool
    let isCodeEditorFocused: FocusState<Bool>.Binding

    init(
        state: FreeCodingQuestionState,
        submitAction: @escaping (PracticeAnswerResult) -> Bool,
        continueAction: @escaping () -> Void,
        allowsRetry: Bool,
        isCodeEditorFocused: FocusState<Bool>.Binding
    ) {
        _state = State(initialValue: state)
        self.submitAction = submitAction
        self.continueAction = continueAction
        self.allowsRetry = allowsRetry
        self.isCodeEditorFocused = isCodeEditorFocused
    }

    var body: some View {
        VStack(spacing: 0) {
            if isCodeEditorFocused.wrappedValue {
                ViewThatFits(in: .vertical) {
                    PracticePromptText(markdown: state.prompt)
                        .fixedSize(horizontal: false, vertical: true)

                    ScrollView {
                        PracticePromptText(markdown: state.prompt)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            } else {
                PracticePromptText(markdown: state.prompt)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TextEditor(text: attributedTextBinding, selection: selectionBinding)
                .textEditorStyle(.plain)
                .practiceAnswerInput()
                .focused(isCodeEditorFocused)
                .disabled(state.isLocked)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.separator, lineWidth: 1)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .accessibilityLabel("Swift code editor")

            // Commented out until we decide if we want to keep it or not; space is super tight on Duo.
//            if isCodeEditorFocused.wrappedValue {
//                FreeCodingSymbolKeypad { symbol in
//                    state.insert(symbol, colorScheme: colorScheme)
//                }
//                .disabled(state.isLocked)
//            }
        }
        .actionBar {
            if isCodeEditorFocused.wrappedValue == false {
                PrimaryActionButton(
                    title: "Submit",
                    systemImage: state.outcome.map { $0 == .correct ? "checkmark" : "xmark" },
                    color: primaryBackground,
                    action: primaryAction
                )
            }
        }
        .onChange(of: colorScheme) { _, newColorScheme in
            state.rehighlight(colorScheme: newColorScheme)
        }
        .onChange(of: state.isLocked) { _, isLocked in
            if isLocked {
                isCodeEditorFocused.wrappedValue = false
            }
        }
        .task {
            state.rehighlight(colorScheme: colorScheme)
            isTipPresented = PracticeTip.freeCoding.claimPresentation()
        }
        .alert(PracticeTip.freeCoding.title, isPresented: $isTipPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(PracticeTip.freeCoding.message)
        }
        .alert("That's not quite right!", isPresented: $isIncorrectAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your code carefully, and try going for the simplest solution that works.")
        }
    }

    private var attributedTextBinding: Binding<AttributedString> {
        Binding(
            get: { state.editor.attributedText },
            set: { text in
                var editor = state.editor
                editor.receiveEditedText(text, colorScheme: colorScheme)
                state.updateEditor(editor)
            }
        )
    }

    private var selectionBinding: Binding<AttributedTextSelection> {
        Binding(
            get: { state.editor.selection },
            set: { selection in
                var editor = state.editor
                editor.selection = selection
                state.updateEditor(editor)
            }
        )
    }

    private func checkAnswer() {
        if let result = state.check(allowsRetry: allowsRetry) {
            if result == .retryableIncorrect {
                isIncorrectAlertPresented = true
            } else {
                _ = submitAction(result)
            }
        }
    }

    private func primaryAction() {
        if state.isLocked {
            continueAction()
        } else {
            checkAnswer()
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
