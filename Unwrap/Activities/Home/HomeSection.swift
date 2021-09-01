//
//  HomeSection.swift
//  HomeSection
//
//  Created by Erik Drobne on 31/08/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation

struct HomeSection {
    let title: String?
    let type: HomeSectionType
    let items: [HomeItem]
}

enum HomeSectionType {
    case status
    case score
    case stats
    case streak
    case badges
}

struct HomeItem {
    var name: String?
    var type: HomeItemType
}

enum HomeItemType {
    case status
    case summary
    case stat(textLabel: String, detailLabel: String, accessibilityLabel: String)
    case share
    case badge
}
