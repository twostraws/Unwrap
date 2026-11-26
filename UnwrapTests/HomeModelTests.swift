//
//  HomeModelTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@Suite("Home models")
struct HomeModelTests {
    @Test("Maximum rank progress is complete")
    func maximumRankProgress() {
        let maximum = RankProgressSnapshot(totalPoints: 100_000)
        #expect(maximum.level == 21)
        #expect(maximum.fraction == 1)
    }

    @Test("A new user starts on level one with a sliver of the ring drawn")
    func emptyProgress() {
        let snapshot = RankProgressSnapshot(totalPoints: 0)

        #expect(snapshot.level == 1)
        #expect(snapshot.fraction == User.smallestRankFraction)
    }

    @Test("Progress is measured across the current level's own point range")
    func fractionWithinLevel() {
        // Level one covers 0 through 199, level two covers 200 through 499.
        let halfwayThroughLevelOne = RankProgressSnapshot(totalPoints: 100)
        let halfwayThroughLevelTwo = RankProgressSnapshot(totalPoints: 350)
        let lastPointOfLevelOne = RankProgressSnapshot(totalPoints: 199)
        let firstPointOfLevelTwo = RankProgressSnapshot(totalPoints: 200)

        #expect(halfwayThroughLevelOne.level == 1)
        #expect(halfwayThroughLevelOne.fraction == 0.5)
        #expect(halfwayThroughLevelTwo.level == 2)
        #expect(halfwayThroughLevelTwo.fraction == 0.5)
        #expect(lastPointOfLevelOne.level == 1)
        #expect(lastPointOfLevelOne.fraction == 0.995)
        #expect(firstPointOfLevelTwo.level == 2)
        #expect(firstPointOfLevelTwo.fraction == User.smallestRankFraction)
    }

    @Test("Snapshots agree with the user's rank either side of every boundary")
    func snapshotMatchesUserRank() {
        for boundary in User.rankLevels.dropLast() {
            for points in [boundary - 1, boundary, boundary + 1] where points >= 0 {
                let user = User()
                user.practicePoints = points
                let snapshot = RankProgressSnapshot(totalPoints: points)

                #expect(snapshot.level == user.rankNumber, "Levels disagree at \(points) points.")
                #expect(snapshot.fraction > 0, "Nothing would be drawn at \(points) points.")
                #expect(snapshot.fraction <= 1, "The ring would overflow at \(points) points.")
            }
        }
    }

    @Test("Progress never moves backwards as points are earned within a level")
    func fractionIsMonotonic() {
        let fractions = stride(from: 200, to: 500, by: 20).map {
            RankProgressSnapshot(totalPoints: $0).fraction
        }

        #expect(fractions == fractions.sorted())
        #expect(Set(fractions).count == fractions.count)
    }

    @Test("Negative totals are treated as zero")
    func negativeTotals() {
        #expect(RankProgressSnapshot(totalPoints: -500) == RankProgressSnapshot(totalPoints: 0))
    }
}
