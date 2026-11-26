//
//  HomeShareItemTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Home sharing")
struct HomeShareItemTests {
    @Test("Score and badge shares preserve their copy and artwork")
    func shareItems() {
        let user = User()
        let badge = Badge(
            name: "Bug Hunter",
            description: "Find it.",
            color: "Badge-Misc",
            symbolName: "ladybug.fill",
            criterion: "practice",
            value: "spot-the-error"
        )

        let score = HomeShareItem.score(for: user)
        let badgeItem = HomeShareItem.badge(badge)

        #expect(score.title == "Unwrap level 1")
        #expect(score.text.contains("Download it here"))
        #expect(score.artwork == .image("Rank Level 1"))
        #expect(badgeItem.title == "Bug Hunter")
        #expect(badgeItem.text.contains("Bug Hunter"))
        #expect(badgeItem.artwork == .badge(symbolName: "ladybug.fill"))
    }

    @Test(
        "The on-demand artwork renderer produces PNG data without a temporary file",
        arguments: [HomeShareItem.Artwork.image("Rank Level 1"), .badge(symbolName: "ladybug.fill")]
    )
    func pngData(artwork: HomeShareItem.Artwork) throws {
        let item = HomeShareItem(
            title: "Test Achievement",
            text: "Test share text",
            artwork: artwork
        )

        let data = try #require(ShareArtwork.pngData(for: item))

        #expect(data.starts(with: [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
        #expect(data.count > 1_000)
    }
}
