//
//  PracticeQuestion.swift
//  Unwrap
//

import Foundation

enum PracticeQuestion: Equatable {
    case review(ReviewQuestionState)
    case typeChecker(TypeCheckerQuestionState)
    case predictOutput(PredictOutputQuestionState)
    case rearrange(RearrangeQuestionState)
    case spotError(SpotErrorQuestionState)
    case tapToCode(TapToCodeQuestionState)
    case freeCoding(FreeCodingQuestionState)

    var prompt: String {
        switch self {
        case .review(let state): state.prompt
        case .typeChecker(let state): state.prompt
        case .predictOutput(let state): state.prompt
        case .rearrange(let state): state.prompt
        case .spotError(let state): state.prompt
        case .tapToCode(let state): state.prompt
        case .freeCoding(let state): state.prompt
        }
    }

    var hint: String {
        switch self {
        case .review(let state): state.hint
        case .typeChecker(let state): state.hint
        case .predictOutput(let state): state.hint
        case .rearrange(let state): state.hint
        case .spotError(let state): state.hint
        case .tapToCode(let state): state.hint
        case .freeCoding(let state): state.hint
        }
    }
}
