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
            guard let conditionChapter = Unwrap.chapters.first(where: {
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
                progress = NSLocalizedString("\n\nYou have not completed anything in this section yet.", comment: "")
            } else {
                progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have completed %d out of %d chapters!", comment: ""), awardedScore / 200, totalSections)
            }

            return progress.centered()

        } else if badge.criterion == "practice" {
            if practiceSessions.count(for: badge.value) < 1 {
                progress = NSLocalizedString("\n\nYou have not practiced with this yet.", comment: "")
            } else if practiceSessions.count(for: badge.value) == 1 {
                progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have practiced %d time!", comment: ""), practiceSessions.count(for: badge.value))
            } else {
                progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have practiced %d times!", comment: ""), practiceSessions.count(for: badge.value))
            }

            return progress.centered()
        } else {
            switch badge.criterion {
            case "streak":
                if bestStreak == 1 {
                    progress = NSLocalizedString("\n\nYou have only played one day.", comment: "")
                } else {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYour best streak is %d days!", comment: ""), bestStreak)
                }

                return progress.centered()

            case "challenge":
                if dailyChallenges.count < 1 {
                    progress = NSLocalizedString("\n\nYou have not completed any challenges yet.", comment: "")
                } else if dailyChallenges.count == 1 {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have completed %d challenge!", comment: ""), dailyChallenges.count)
                } else {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have completed %d challenges!", comment: ""), dailyChallenges.count)
                }

                return progress.centered()

            case "news":
                if readNewsCount < 1 {
                    progress = NSLocalizedString("\n\nYou have not read any news articles yet.", comment: "")
                } else if readNewsCount == 1 {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have read %d news article!", comment: ""), readNewsCount)
                } else {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have read %d news articles!", comment: ""), readNewsCount)
                }

                return progress.centered()

            case "share":
                if scoreShareCount < 1 {
                    progress = NSLocalizedString("\n\nYou have not shared your score yet.", comment: "")
                } else if scoreShareCount == 1 {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have shared your score %d time!", comment: ""), scoreShareCount)
                } else {
                    progress = .localizedStringWithFormat(NSLocalizedString("\n\nYou have shared your score %d times!", comment: ""), scoreShareCount)
                }

                return progress.centered()

            default:
                fatalError("Unknown badge criterion: \(badge.criterion)")
            }
        }
    }
}
