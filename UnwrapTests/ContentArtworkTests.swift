//
//  ContentArtworkTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

/// Artwork is looked up by names built at runtime, so a renamed badge or a missing image
/// only shows up as a blank space in the app. These load every one of those names.
@Suite("Shipped artwork")
struct ContentArtworkTests {
    @Test("Every badge has its icon and tint color in the asset catalog")
    func badgeArtwork() throws {
        let badges = try Bundle.main.decode([Badge].self, from: "Badges.json")

        #expect(badges.isEmpty == false)

        for badge in badges {
            #expect(UIImage(systemName: badge.symbolName) != nil, "No symbol \(badge.symbolName) for \(badge.name).")
            #expect(UIColor(named: badge.color) != nil, "Missing color \(badge.color) for \(badge.name).")
        }
    }

    @Test("Every rank a user can reach has share artwork")
    func rankArtwork() {
        let highestRank = User.rankLevels.count - 1

        for rank in 1...highestRank {
            #expect(UIImage(named: "Rank Level \(rank)") != nil, "Missing artwork for rank \(rank).")
        }
    }

    @Test("Sharing a score uses artwork that exists at every rank boundary")
    func scoreShareArtwork() {
        for boundary in User.rankLevels.dropLast() {
            let user = User()
            user.practicePoints = boundary
            let item = HomeShareItem.score(for: user)

            #expect(item.artwork == .image("Rank Level \(user.rankNumber)"))
            #expect(UIImage(named: "Rank Level \(user.rankNumber)") != nil, "Missing artwork at \(boundary) points.")
            #expect(item.title == "Unwrap level \(user.rankNumber)")
            #expect(item.text.contains("level \(user.rankNumber) "))
        }
    }

    @Test("Every practice activity has its catalog icon")
    func practiceArtwork() {
        for kind in PracticeKind.allCases {
            #expect(UIImage(systemName: kind.symbolName) != nil, "No symbol \(kind.symbolName).")
        }
    }

    @Test("Every tour page has its image")
    func tourArtwork() throws {
        let items = try Bundle.main.decode([TourItem].self, from: "Tour.json")

        #expect(items.isEmpty == false)

        for item in items {
            #expect(UIImage(named: item.image) != nil, "Missing tour image \(item.image).")
        }
    }

    @Test("Every lesson has the image shown at the top of its page")
    func lessonArtwork() {
        for title in Unwrap.chapters.flatMap(\.sections) {
            #expect(UIImage(named: title.bundleName) != nil, "Missing image for \(title).")
        }
    }
}
