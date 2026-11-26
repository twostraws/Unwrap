//
//  HomeShareItem.swift
//  Unwrap
//

import Foundation

nonisolated struct HomeShareItem: Equatable, Identifiable, Sendable {
    /// What to draw above the logo in the shared image.
    enum Artwork: Equatable, Sendable {
        case image(String)
        case badge(symbolName: String)
    }

    let title: String
    let text: String
    let artwork: Artwork

    var id: String { title }

    @MainActor
    static func score(for user: User) -> HomeShareItem {
        HomeShareItem(
            title: "Unwrap level \(user.rankNumber)",
            text: "I'm on level \(user.rankNumber) in Unwrap by @twostraws. Download it here: \(Unwrap.appURL)",
            artwork: .image("Rank Level \(user.rankNumber)")
        )
    }

    @MainActor
    static func badge(_ badge: Badge) -> HomeShareItem {
        HomeShareItem(
            title: badge.name,
            text: "I earned the badge \(badge.name) in Unwrap by @twostraws. Download it here: \(Unwrap.appURL)",
            artwork: .badge(symbolName: badge.symbolName)
        )
    }
}
