//
//  LearnReviewFlowTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Learn review and award flow", .serialized)
struct LearnReviewFlowTests {
    @Test("Study without a postscript routes through review and ends at its award")
    func studyWithoutPostscript() throws {
        let id = "variables"
        let user = User()
        var flow = LearnStudyFlow(lessonID: id, initialProgress: .unstarted)

        #expect(flow.stage == .study)
        let prematureAward = flow.finishReview(outcome: .completed, user: user)
        #expect(prematureAward == nil)

        flow.finishStudying(hasPostscript: false)
        #expect(flow.stage == .review)

        let pendingAward = flow.finishReview(outcome: .completed, user: user)
        let award = try #require(pendingAward)
        #expect(award.earnedPoints == 200)
        #expect(user.hasReviewed(id))
        #expect(flow.stage == .award)
        let repeatedAward = flow.finishReview(outcome: .completed, user: user)
        #expect(repeatedAward == nil)
        #expect(flow.stage == .award)
    }

    @Test("Study with a postscript cannot bypass its review route")
    func studyWithPostscript() {
        var flow = LearnStudyFlow(
            lessonID: "variables",
            initialProgress: .unstarted
        )

        flow.finishStudying(hasPostscript: true)
        #expect(flow.stage == .postscript)

        flow.finishStudying(hasPostscript: false)
        #expect(flow.stage == .postscript)

        flow.continueFromPostscript()
        #expect(flow.stage == .review)

        flow.continueFromPostscript()
        #expect(flow.stage == .review)
    }

    @Test("Each award branch grants the right points and progress exactly once")
    func awardMutationBranches() throws {
        let id = "variables"
        let expectations = [
            MutationExpectation(progress: .unstarted, outcome: .completed, earnedPoints: 200, hasReviewed: true),
            MutationExpectation(progress: .unstarted, outcome: .skipped, earnedPoints: 100, hasReviewed: false),
            MutationExpectation(progress: .learned, outcome: .completed, earnedPoints: 100, hasReviewed: true),
            MutationExpectation(progress: .learned, outcome: .skipped, earnedPoints: 0, hasReviewed: false),
            MutationExpectation(progress: .reviewed, outcome: .completed, earnedPoints: 0, hasReviewed: true),
            MutationExpectation(progress: .reviewed, outcome: .skipped, earnedPoints: 0, hasReviewed: true)
        ]

        for expectation in expectations {
            let branch = "\(expectation.progress), \(expectation.outcome)"
            let user = makeUser(progress: expectation.progress, lessonID: id)
            let startingPoints = user.totalPoints
            var flow = LearnStudyFlow(
                lessonID: id,
                initialProgress: expectation.progress
            )
            flow.finishStudying(hasPostscript: false)
            let pendingAward = flow.finishReview(outcome: expectation.outcome, user: user)
            let model = try #require(pendingAward)

            #expect(model.earnedPoints == expectation.earnedPoints, "Wrong award for \(branch).")
            #expect(model.startingTotal == startingPoints, "Wrong starting total for \(branch).")
            #expect(user.totalPoints == startingPoints + expectation.earnedPoints, "Wrong total for \(branch).")
            #expect(user.hasLearned(id), "\(branch) should leave the lesson learned.")
            #expect(user.hasReviewed(id) == expectation.hasReviewed, "Wrong review state for \(branch).")

            let repeatedAward = flow.finishReview(outcome: expectation.outcome, user: user)
            #expect(repeatedAward == nil)
            #expect(user.totalPoints == startingPoints + expectation.earnedPoints)
        }
    }

    @Test(
        "Skipping review of an existing lesson leaves all user progress unchanged",
        arguments: [LessonProgress.learned, .reviewed]
    )
    func skippingReviewAfterLearning(progress: LessonProgress) throws {
        let id = "variables"
        let user = makeUser(progress: progress, lessonID: id)
        user.practicePoints = 17
        let startingPoints = user.totalPoints
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let originalProgress = try encoder.encode(user)
        var flow = LearnStudyFlow(lessonID: id, initialProgress: progress)

        flow.finishStudying(hasPostscript: false)
        let pendingAward = flow.finishReview(outcome: .skipped, user: user)
        let model = try #require(pendingAward)

        #expect(model.earnedPoints == 0)
        #expect(model.startingTotal == startingPoints)
        #expect(model.endingTotal == startingPoints)
        #expect(model.crossesLevelBoundary == false)
        #expect(flow.stage == .award)
        #expect(try encoder.encode(user) == originalProgress)

        let repeatedAward = flow.finishReview(outcome: .completed, user: user)
        #expect(repeatedAward == nil)
        #expect(try encoder.encode(user) == originalProgress)
    }

    @Test("Lesson progress is reviewed, else learned, else unstarted")
    func lessonProgress() {
        #expect(LessonProgress(hasLearned: false, hasReviewed: false) == .unstarted)
        #expect(LessonProgress(hasLearned: true, hasReviewed: false) == .learned)
        #expect(LessonProgress(hasLearned: true, hasReviewed: true) == .reviewed)
        #expect(LessonProgress(hasLearned: false, hasReviewed: true) == .reviewed)
    }

    private func makeUser(progress: LessonProgress, lessonID: String) -> User {
        let user = User()

        switch progress {
        case .unstarted:
            break
        case .learned:
            user.learnedSection(lessonID)
        case .reviewed:
            user.reviewedSection(lessonID)
        }

        return user
    }

    private struct MutationExpectation {
        let progress: LessonProgress
        let outcome: LearnReviewOutcome
        let earnedPoints: Int
        let hasReviewed: Bool
    }
}
