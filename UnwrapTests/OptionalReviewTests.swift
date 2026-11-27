import Foundation
import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test func optionalReviewScheduleAndPersistence() throws {
        let start = Date(timeIntervalSince1970: 1_600_000_000)
        let user = try JSONDecoder().decode(User.self, from: Data("{}".utf8))
        #expect(user.optionalReview == nil)
        user.recordOptionalReview(outcome: .missed, at: start)
        let first = try #require(user.optionalReview)
        #expect(first.outcome == .missed)
        #expect(first.exampleIndex == 0)
        #expect(!first.isDue(at: start))
        user.recordOptionalReview(outcome: .independent, at: start)
        #expect(user.optionalReview == first)
        user.recordOptionalReview(outcome: .independent, at: first.nextReview)
        let next = try #require(user.optionalReview)
        #expect(next.exampleIndex == 1)
        #expect(next.outcome == .independent)
        let assisted = OptionalReviewRecord(previous: nil, outcome: .assisted, date: start)
        #expect(assisted.outcome == .assisted)
        #expect(assisted.nextReview == first.nextReview)
        #expect(next.nextReview.timeIntervalSince(first.nextReview) > 6 * 86400)
        let loaded = try JSONDecoder().decode(User.self, from: JSONEncoder().encode(user))
        #expect(loaded.optionalReview == next)
        loaded.resetProgress()
        user.replaceProgress(with: loaded)
        #expect(user.optionalReview == nil)
    }
}
