//
//  PracticeTip.swift
//  Unwrap
//

import Foundation

enum PracticeTip {
    case freeCoding
    case spotTheError

    var userDefaultsKey: String {
        switch self {
        case .freeCoding:
            "ShownFreeCoding"
        case .spotTheError:
            "ShownSpotTheError"
        }
    }

    var title: String {
        "Tip"
    }

    var message: String {
        switch self {
        case .freeCoding:
            "Unwrap is able to understand a variety of different solutions to each problem, but it's not perfect. If you enter a valid solution that is not accepted, please let us know so we can add it and make Unwrap better for everyone!"
        case .spotTheError:
            "You should mentally run the code from top to bottom, meaning that if line 3 says an integer should be returned and line 10 tries to return a string, line 10 is the wrong one."
        }
    }

    func claimPresentation(defaults: UserDefaults = .standard) -> Bool {
        guard defaults.bool(forKey: userDefaultsKey) == false else {
            return false
        }

        defaults.set(true, forKey: userDefaultsKey)
        return true
    }
}
