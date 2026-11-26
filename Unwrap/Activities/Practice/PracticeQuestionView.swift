//
//  PracticeQuestionView.swift
//  Unwrap
//

import SwiftUI

struct PracticeQuestionView: View {
    let question: PracticeQuestion
    let submitAction: (PracticeAnswerResult) -> Bool
    let continueAction: () -> Void
    let isCodeEditorFocused: FocusState<Bool>.Binding
    let allowsRetry: Bool

    init(
        question: PracticeQuestion,
        submitAction: @escaping (PracticeAnswerResult) -> Bool,
        continueAction: @escaping () -> Void,
        isCodeEditorFocused: FocusState<Bool>.Binding,
        allowsRetry: Bool = true
    ) {
        self.question = question
        self.submitAction = submitAction
        self.continueAction = continueAction
        self.isCodeEditorFocused = isCodeEditorFocused
        self.allowsRetry = allowsRetry
    }

    @ViewBuilder
    var body: some View {
        switch question {
        case .review(let state):
            ReviewQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .typeChecker(let state):
            TypeCheckerQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .predictOutput(let state):
            PredictOutputQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .rearrange(let state):
            RearrangeQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .spotError(let state):
            SpotErrorQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .tapToCode(let state):
            TapToCodeQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction
            )
        case .freeCoding(let state):
            FreeCodingQuestionView(
                state: state,
                submitAction: submitAction,
                continueAction: continueAction,
                allowsRetry: allowsRetry,
                isCodeEditorFocused: isCodeEditorFocused
            )
        }
    }
}
