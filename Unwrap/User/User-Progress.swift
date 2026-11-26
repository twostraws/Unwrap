//
//  User-Progress.swift
//  Unwrap
//
//  Created by Wayne Nihart on 4/27/19.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import Foundation

extension User {
    /// Returns true if a specific badge has been earned, or false otherwise.
    func isBadgeEarned(_ badge: Badge) -> Bool {
        if badge.criterion == "read" {
            guard var conditionChapter = Unwrap.chapters.first(where: {
                $0.name.bundleName == badge.value

            }) else {
                fatalError("Unknown chapter name for criterion: \(badge.value).")
            }

            return conditionChapter.bundleNameSections.allSatisfy {
                hasReviewed($0.bundleName)
            }
        } else if badge.criterion == "practice" {
            let practiceBadgeCount = 10
            return practiceSessions.count(for: badge.value) >= practiceBadgeCount
        } else {
            guard let intValue = Int(badge.value) else {
                fatalError("Criterion must have its value specified as an integer: \(badge.criterion).")
            }

            switch badge.criterion {
            case "streak":
                return bestStreak >= intValue

            case "challenge":
                return dailyChallenges.count >= intValue

            case "news":
                return readNewsCount >= intValue

            default:
                fatalError("Unknown badge criterion: \(badge.criterion)")
            }
        }
    }

    /// Returns a user-facing summary of progress toward a badge.
    func badgeProgress(_ badge: Badge) -> String {
        let progress: String

        if badge.criterion == "read" {
            guard let conditionChapter = Unwrap.chapters.first(where: {
                $0.name.bundleName == badge.value

            }) else {
                fatalError("Unknown chapter name for criterion: \(badge.value).")
            }

            var awardedScore = 0
            let totalSections = conditionChapter.sections.count

            for section in conditionChapter.sections {
                let score = ratingForSection(section.bundleName)
                if score == 100 {
                    awardedScore += 0
                } else {
                    awardedScore += score
                }
            }

            if awardedScore > totalSections * 200 {
                fatalError("awardedScore (\(awardedScore)) cannot exceed amount possible for the section (\(totalSections * 200)).")
            }

            if awardedScore == 0 {
                progress = "\n\nYou have not completed anything in this section yet."
            } else {
                progress = "\n\nYou have completed \(awardedScore / 200) out of \(totalSections) chapters!"
            }

            return progress

        } else if badge.criterion == "practice" {
            if practiceSessions.count(for: badge.value) < 1 {
                progress = "\n\nYou have not practiced with this yet."
            } else if practiceSessions.count(for: badge.value) == 1 {
                progress = "\n\nYou have practiced \(practiceSessions.count(for: badge.value)) time!"
            } else {
                progress = "\n\nYou have practiced \(practiceSessions.count(for: badge.value)) times!"
            }

            return progress
        } else {
            switch badge.criterion {
            case "streak":
                if bestStreak == 1 {
                    progress = "\n\nYou have only played one day."
                } else {
                    progress = "\n\nYour best streak is \(bestStreak) days!"
                }

                return progress

            case "challenge":
                if dailyChallenges.count < 1 {
                    progress = "\n\nYou have not completed any challenges yet."
                } else if dailyChallenges.count == 1 {
                    progress = "\n\nYou have completed \(dailyChallenges.count) challenge!"
                } else {
                    progress = "\n\nYou have completed \(dailyChallenges.count) challenges!"
                }

                return progress

            case "news":
                if readNewsCount < 1 {
                    progress = "\n\nYou have not read any news articles yet."
                } else if readNewsCount == 1 {
                    progress = "\n\nYou have read \(readNewsCount) news article!"
                } else {
                    progress = "\n\nYou have read \(readNewsCount) news articles!"
                }

                return progress

            default:
                fatalError("Unknown badge criterion: \(badge.criterion)")
            }
        }
    }
}
