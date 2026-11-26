//
//  PracticeKind.swift
//  Unwrap
//

import Foundation

enum PracticeKind: String, CaseIterable, Codable, Identifiable {
    case freeCoding = "free-coding"
    case predictTheOutput = "predict-the-output"
    case rearrangeTheLines = "rearrange-the-lines"
    case review
    case spotTheError = "spot-the-error"
    case tapToCode = "tap-to-code"
    case typeChecker = "type-practice"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .freeCoding: "Free Coding"
        case .predictTheOutput: "Predict the Output"
        case .rearrangeTheLines: "Rearrange the Lines"
        case .review: "Review"
        case .spotTheError: "Spot the Error"
        case .tapToCode: "Tap to Code"
        case .typeChecker: "Type Checker"
        }
    }

    var sessionTitle: String {
        self == .typeChecker ? "Type Practice" : title
    }

    var subtitle: String {
        switch self {
        case .freeCoding: "Write code to solve problems"
        case .predictTheOutput: "Read code then predict the output"
        case .rearrangeTheLines: "Rearrange code to make it build"
        case .review: "Go over questions you've already learned"
        case .spotTheError: "Master Swift's type system through examples"
        case .tapToCode: "Build working code by tapping components"
        case .typeChecker: "Identify data types more easily"
        }
    }

    var unlockSectionID: String {
        switch self {
        case .freeCoding: "typecasting"
        case .predictTheOutput: "functions-summary"
        case .rearrangeTheLines: "mutability"
        case .review: "variables"
        case .spotTheError: "default-parameters"
        case .tapToCode: "infinite-loops"
        case .typeChecker: "type-annotations"
        }
    }

    var unlockSectionTitle: String {
        switch self {
        case .freeCoding: "Typecasting"
        case .predictTheOutput: "Functions: Summary"
        case .rearrangeTheLines: "Mutability"
        case .review: "Variables"
        case .spotTheError: "Default parameters"
        case .tapToCode: "Infinite Loops"
        case .typeChecker: "Type annotations"
        }
    }

    var symbolName: String {
        switch self {
        case .freeCoding: "keyboard.fill"
        case .predictTheOutput: "questionmark.circle.fill"
        case .rearrangeTheLines: "arrow.up.arrow.down"
        case .review: "graduationcap.fill"
        case .spotTheError: "magnifyingglass"
        case .tapToCode: "hand.tap.fill"
        case .typeChecker: "target"
        }
    }

    var lockedMessage: String {
        "You need to complete the chapter \"\(unlockSectionTitle)\" before you can practice this."
    }

    func isUnlocked(for user: User) -> Bool {
        user.ratingForSection(unlockSectionID) != 0
    }
}
