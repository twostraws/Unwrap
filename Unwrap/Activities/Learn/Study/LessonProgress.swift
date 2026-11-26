//
//  LessonProgress.swift
//  Unwrap
//

import Foundation

enum LessonProgress: Equatable {
    case unstarted
    case learned
    case reviewed

    init(hasLearned: Bool, hasReviewed: Bool) {
        if hasReviewed {
            self = .reviewed
        } else if hasLearned {
            self = .learned
        } else {
            self = .unstarted
        }
    }
}
