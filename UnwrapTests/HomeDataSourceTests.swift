//
//  HomeDataSourceTests.swift
//  HomeDataSourceTests
//
//  Created by Erik Drobne on 01/09/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import XCTest
@testable import Unwrap

class HomeDataSourceTests: XCTestCase {

    /// Create an instance of HomeDataSource
    let dataSource = HomeDataSource()

    func testBadges() {
        let user = User()

        XCTAssertEqual(dataSource.badges.count, 25)
        let badge = dataSource.badges[10]
        XCTAssertFalse(user.isBadgeEarned(badge))
    }

    func testSections() {
        XCTAssertEqual(dataSource.sections.count, 5)

        let types: [HomeSectionType] = [.status, .score, .stats, .streak, .badges]
        XCTAssertTrue(dataSource.sections.map({ $0.type }).elementsEqual(types))

        let titles = [nil, "POINTS", "STATS", "STREAK", "BADGES"]
        XCTAssertTrue(dataSource.sections.map({ $0.title }).elementsEqual(titles))
    }

    func testStatusSection() {
        let section = dataSource.sections.first(where: { $0.type == .status })
        XCTAssertEqual(section?.items.count, 2)
    }

    func testScoreSection() {
        let section = dataSource.sections.first(where: { $0.type == .score })
        XCTAssertEqual(section?.items.count, 5)
    }

    func testStatsSection() {
        let section = dataSource.sections.first(where: { $0.type == .stats })
        XCTAssertEqual(section?.items.count, 3)
    }

    func testStreakSection() {
        let section = dataSource.sections.first(where: { $0.type == .streak })
        XCTAssertEqual(section?.items.count, 2)
    }

    func testBadgesSection() {
        let section = dataSource.sections.first(where: { $0.type == .badges })
        XCTAssertEqual(section?.items.count, dataSource.badges.count)
    }
}
