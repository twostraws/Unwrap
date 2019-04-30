//
//  User-Progress.swift
//  Unwrap
//
//  Created by Wayne Nihart on 4/27/19.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension User {
    /// Returns an NSAttributedString to display progress in an alert.
    func badgeProgress(_ badge: Badge) -> NSAttributedString {
        let progress: String

        if badge.criterion == "read" {
            guard var conditionChapter = Unwrap.chapters.first(where: {
                $0.name.bundleName == badge.value

            }) else {
                fatalError("Unknown chapter name for criterion: \(badge.value).")
            }

            var awardedScore = 0
            let totalSections = conditionChapter.sections.count

            for i in 1...totalSections {
                let section = conditionChapter.sections[i-1]
                let score = User.current.ratingForSection(section.bundleName)
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
                progress = "\n\nYou haven't completed anything is this section yet."
            } else {
                progress = "\n\nYou have completed \(awardedScore / 200) out of \(totalSections) chapters!"
            }

            return progress.centered()

        } else if badge.criterion == "practice" {
            if practiceSessions.count(for: badge.value) < 1 {
                progress = "\n\nYou have not practiced with this yet."
            } else if practiceSessions.count(for: badge.value) == 1 {
                progress = "\n\nYou have practiced \(practiceSessions.count(for: badge.value)) time!"
            } else {
                progress = "\n\nYou have practiced \(practiceSessions.count(for: badge.value)) times!"
            }

            return progress.centered()
        } else {
            switch badge.criterion {
            case "streak":
                if bestStreak == 1 {
                    progress = "You have only played one day."
                } else {
                    progress = "\n\nYour best streak is \(bestStreak) days!"
                }

                return progress.centered()

            case "challenge":
                if dailyChallenges.count < 1 {
                    progress = "\n\nYou have not completed any challenges yet."
                } else if dailyChallenges.count == 1 {
                    progress = "\n\nYou have completed \(dailyChallenges.count) challenge!"
                } else {
                    progress = "\n\nYou have completed \(dailyChallenges.count) challenges!"
                }

                return progress.centered()

            case "news":
                if readNewsCount < 1 {
                    progress = "\n\nYou have not read any news articles yet."
                } else if readNewsCount == 1 {
                    progress = "\n\nYou have read \(readNewsCount) news article!"
                } else {
                    progress = "\n\nYou have read \(readNewsCount) news article!"
                }

                return progress.centered()

            case "share":
                if scoreShareCount < 1 {
                    progress = "\n\nYou have not shared your score yet."
                } else if scoreShareCount == 1 {
                    progress = "\n\nYou have shared your score \(scoreShareCount) time!"
                } else {
                    progress = "\n\nYou have shared your score \(scoreShareCount) times!"
                }

                return progress.centered()

            default:
                fatalError("Unknown badge criterion: \(badge.criterion)")
            }
        }
    }
}
