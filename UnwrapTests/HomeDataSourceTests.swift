//
//  HomeDataSourceTests.swift
//  HomeDataSourceTests
//
//  Created by Erik Drobne on 01/09/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Testing
@testable import Unwrap

extension UserCoreTests {
    @Test("Home exposes every badge to a new user without earning it")
    func homeBadges() throws {
        try withFreshHomeDataSource { dataSource in
            let user = User()

            #expect(dataSource.badges.count == 25)
            try #require(dataSource.badges.indices.contains(10))
            #expect(user.isBadgeEarned(dataSource.badges[10]) == false)
        }
    }

    @Test("Home sections have the expected order and titles")
    func homeSectionMetadata() {
        withFreshHomeDataSource { dataSource in
            #expect(dataSource.sections.count == 5)
            #expect(dataSource.sections.map(\.type) == [.status, .score, .stats, .streak, .badges])
            #expect(dataSource.sections.map(\.title) == [nil, "POINTS", "STATS", "STREAK", "BADGES"])
        }
    }

    @Test(
        "Each home section has the expected item count",
        arguments: [
            (0, 2),
            (1, 5),
            (2, 3),
            (3, 2),
            (4, 25)
        ]
    )
    func homeSectionItemCounts(sectionIndex: Int, expectedCount: Int) throws {
        try withFreshHomeDataSource { dataSource in
            try #require(dataSource.sections.indices.contains(sectionIndex))
            #expect(dataSource.sections[sectionIndex].items.count == expectedCount)

            if dataSource.sections[sectionIndex].type == .badges {
                #expect(dataSource.sections[sectionIndex].items.count == dataSource.badges.count)
            }
        }
    }

    private func withFreshHomeDataSource<T>(_ operation: (HomeDataSource) throws -> T) rethrows -> T {
        let previousUser: User? = User.current
        User.current = User()
        defer { User.current = previousUser }
        return try operation(HomeDataSource())
    }
}
