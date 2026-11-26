//
//  LearnStudyFlowView.swift
//  Unwrap
//

import SwiftUI

struct LearnStudyFlowView: View {

    @State private var flow: LearnStudyFlow
    @State private var reviewSession: ReviewSession
    @State private var awardModel: AwardModel?

    let lesson: Lesson
    let user: User
    let openBrowser: @MainActor @Sendable (URL) -> Void
    let onFinished: () -> Void

    init(
        lesson: Lesson,
        user: User,
        random: any RandomProviding = SystemRandomSource(),
        openBrowser: @escaping @MainActor @Sendable (URL) -> Void,
        onFinished: @escaping () -> Void
    ) {
        let progress = LessonProgress(
            hasLearned: user.hasLearned(lesson.id),
            hasReviewed: user.hasReviewed(lesson.id)
        )

        self.lesson = lesson
        self.user = user
        self.openBrowser = openBrowser
        self.onFinished = onFinished
        _flow = State(
            initialValue: LearnStudyFlow(
                lessonID: lesson.id,
                initialProgress: progress
            )
        )
        _reviewSession = State(
            initialValue: ReviewSession(content: lesson.review, random: random)
        )
    }

    var body: some View {
        Group {
            switch flow.stage {
            case .study, .postscript:
                LessonStudyView(
                    lesson: lesson,
                    openBrowser: openBrowser,
                    continueAction: finishStudying
                )
                .alert(lesson.title, isPresented: showsPostscript) {
                    Button("OK", action: continueFromPostscript)
                } message: {
                    MarkdownText(markdown: lesson.review.postscript)
                }
            case .review:
                ReviewSessionView(
                    session: $reviewSession,
                    completedAction: completeReview,
                    skippedAction: skipReview
                )
            case .award:
                if let awardModel {
                    AwardView(model: awardModel, continueAction: onFinished)
                } else {
                    ContentUnavailableView(
                        "Award Unavailable",
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var showsPostscript: Binding<Bool> {
        Binding(
            get: { flow.stage == .postscript },
            set: { _ in }
        )
    }

    private func finishStudying() {
        flow.finishStudying(hasPostscript: lesson.review.postscript.isEmpty == false)
    }

    private func continueFromPostscript() {
        flow.continueFromPostscript()
    }

    private func completeReview() {
        presentAward(for: .completed)
    }

    private func skipReview() {
        presentAward(for: .skipped)
    }

    private func presentAward(for outcome: LearnReviewOutcome) {
        awardModel = flow.finishReview(outcome: outcome, user: user)
    }
}
