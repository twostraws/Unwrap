//
//  HomeContent.swift
//  Unwrap
//

import Foundation

struct HomeContent {
    let badges: [Badge]
    let helpItems: [HelpItem]
    let tourItems: [TourItem]
    let creditsMarkdown: String

    init(badges: [Badge], helpItems: [HelpItem], tourItems: [TourItem], creditsMarkdown: String) {
        self.badges = badges
        self.helpItems = helpItems
        self.tourItems = tourItems
        self.creditsMarkdown = creditsMarkdown
    }

    init(bundle: Bundle = .main) throws {
        badges = try bundle.decode([Badge].self, from: "Badges.json")
        helpItems = try bundle.decode([HelpItem].self, from: "Help.json")
        tourItems = try bundle.decode([TourItem].self, from: "Tour.json")
        creditsMarkdown = try bundle.text(named: "Credits.md")
    }
}
