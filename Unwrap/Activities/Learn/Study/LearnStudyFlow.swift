//
//  LearnStudyFlow.swift
//  Unwrap
//

import Foundation

struct LearnStudyFlow {
    private let lessonID: String
    private let initialProgress: LessonProgress
    private(set) var stage: LearnStudyStage

    init(
        lessonID: String,
        initialProgress: LessonProgress
    ) {
        self.lessonID = lessonID
        self.initialProgress = initialProgress
        stage = .study
    }

    mutating func finishStudying(hasPostscript: Bool) {
        guard stage == .study else { return }
        stage = hasPostscript ? .postscript : .review
    }

    mutating func continueFromPostscript() {
        guard stage == .postscript else { return }
        stage = .review
    }

    @discardableResult
    mutating func finishReview(
        outcome: LearnReviewOutcome,
        user: User,
        date: Date = .now
    ) -> AwardModel? {
        guard stage == .review else { return nil }

        let award = makeAward(for: outcome, user: user, date: date)
        stage = .award
        return award
    }

    private func makeAward(
        for outcome: LearnReviewOutcome,
        user: User,
        date: Date
    ) -> AwardModel {
        switch (initialProgress, outcome) {
        case (.unstarted, .completed):
            AwardModel.applying(
                points: User.pointsForLearning + User.pointsForReviewing,
                reason: .review(section: lessonID),
                date: date,
                to: user
            )
        case (.unstarted, .skipped):
            AwardModel.applying(
                points: User.pointsForLearning,
                reason: .learning(section: lessonID),
                date: date,
                to: user
            )
        case (.learned, .completed):
            AwardModel.applying(
                points: User.pointsForReviewing,
                reason: .review(section: lessonID),
                date: date,
                to: user
            )
        case (.learned, .skipped), (.reviewed, .skipped):
            AwardModel.unchanged(for: user)
        case (.reviewed, .completed):
            AwardModel.applying(
                points: 0,
                reason: .review(section: lessonID),
                date: date,
                to: user
            )
        }
    }
}
