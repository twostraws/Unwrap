//
//  RankProgressSnapshot.swift
//  Unwrap
//

struct RankProgressSnapshot: Equatable {
    let level: Int
    let fraction: Double

    init(totalPoints: Int) {
        let totalPoints = max(0, totalPoints)
        level = User.rankLevels.firstIndex { $0 > totalPoints }
            ?? (User.rankLevels.count - 1)

        if level == User.rankLevels.count - 1 {
            fraction = 1
        } else {
            let lowerBound = User.rankLevels[level - 1]
            let upperBound = User.rankLevels[level]
            let distance = upperBound - lowerBound
            fraction = max(Double(totalPoints - lowerBound) / Double(distance), User.smallestRankFraction)
        }
    }
}
