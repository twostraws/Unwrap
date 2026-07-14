//
//  DataSourceBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

@Suite("Data-source behavior", .serialized)
struct DataSourceBehaviorTests {
    @Test("Glossary entries are grouped and indexed alphabetically")
    func glossaryGrouping() {
        let dataSource = GlossaryDataSource()
        let tableView = UITableView()
        let entries = [
            GlossaryEntry(term: "closure", description: "A closure"),
            GlossaryEntry(term: "Array", description: "An array"),
            GlossaryEntry(term: "actor", description: "An actor"),
            GlossaryEntry(term: "Zebra", description: "A zebra")
        ]

        dataSource.createSortedEntriesAndTitles(from: entries)

        #expect(dataSource.sectionTitles == ["A", "C", "Z"])
        #expect(dataSource.sortedEntries["A"]?.map(\.term) == ["Array", "actor"])
        #expect(dataSource.sortedEntries["C"]?.map(\.term) == ["closure"])
        #expect(dataSource.sortedEntries["Z"]?.map(\.term) == ["Zebra"])
        #expect(dataSource.numberOfSections(in: tableView) == 3)
        #expect(dataSource.sectionIndexTitles(for: tableView) == ["A", "C", "Z"])

        for section in dataSource.sectionTitles.indices {
            let title = dataSource.sectionTitles[section]
            #expect(dataSource.tableView(tableView, titleForHeaderInSection: section) == title)
            #expect(dataSource.tableView(tableView, numberOfRowsInSection: section) == dataSource.sortedEntries[title]?.count)
        }
    }

    @Test("Glossary search follows localized user-input matching and restores all entries")
    func glossaryFiltering() {
        let dataSource = GlossaryDataSource()
        let searchController = UISearchController(searchResultsController: nil)
        dataSource.originalEntries = [
            GlossaryEntry(term: "Résumé", description: "A summary"),
            GlossaryEntry(term: "Result", description: "A value"),
            GlossaryEntry(term: "Closure", description: "A closure")
        ]

        searchController.searchBar.text = "  resume\n"
        dataSource.updateSearchResults(for: searchController)

        #expect(dataSource.sectionTitles == ["R"])
        #expect(dataSource.sortedEntries["R"]?.map(\.term) == ["Résumé"])

        searchController.searchBar.text = "RESULT"
        dataSource.updateSearchResults(for: searchController)

        #expect(dataSource.sortedEntries["R"]?.map(\.term) == ["Result"])

        searchController.searchBar.text = " \t "
        dataSource.updateSearchResults(for: searchController)

        #expect(dataSource.sectionTitles == ["C", "R"])
        #expect(dataSource.sortedEntries.values.flatMap { $0 }.count == 3)
    }

    @Test("Learn sections, row counts, and titles map to the chapter catalog")
    func learnMapping() {
        let dataSource = LearnDataSource()
        let tableView = UITableView()

        #expect(dataSource.numberOfSections(in: tableView) == Unwrap.chapters.count)

        for (section, chapter) in Unwrap.chapters.enumerated() {
            #expect(dataSource.tableView(tableView, numberOfRowsInSection: section) == chapter.sections.count)

            for (row, title) in chapter.sections.enumerated() {
                #expect(dataSource.title(for: IndexPath(row: row, section: section)) == title)
            }
        }
    }

    @Test("Empty challenge history has a placeholder row and cannot be edited")
    func emptyChallengeHistory() {
        let previousUser: User? = User.current
        defer { User.current = previousUser }

        User.current = User()
        let dataSource = ChallengesDataSource()
        let tableView = UITableView()

        #expect(dataSource.numberOfSections(in: tableView) == 2)
        #expect(dataSource.tableView(tableView, titleForHeaderInSection: 0) == "Today's challenge")
        #expect(dataSource.tableView(tableView, titleForHeaderInSection: 1) == "Previous challenges")
        #expect(dataSource.tableView(tableView, titleForFooterInSection: 0) == nil)
        #expect(dataSource.tableView(tableView, titleForFooterInSection: 1) == nil)
        #expect(dataSource.tableView(tableView, numberOfRowsInSection: 0) == 1)
        #expect(dataSource.tableView(tableView, numberOfRowsInSection: 1) == 1)
        #expect(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)) == false)
        #expect(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 1)) == false)
    }

    @Test("Populated challenge history exposes every result as editable")
    func populatedChallengeHistory() {
        let previousUser: User? = User.current
        defer { User.current = previousUser }

        let user = User()
        user.dailyChallenges = [
            ChallengeResult(date: Date(timeIntervalSince1970: 1_000), score: 50),
            ChallengeResult(date: Date(timeIntervalSince1970: 2_000), score: 100)
        ]
        User.current = user

        let dataSource = ChallengesDataSource()
        let tableView = UITableView()

        #expect(dataSource.tableView(tableView, titleForFooterInSection: 0) == nil)
        #expect(dataSource.tableView(tableView, titleForFooterInSection: 1) == "Tap any date to share your score.")
        #expect(dataSource.tableView(tableView, numberOfRowsInSection: 0) == 1)
        #expect(dataSource.tableView(tableView, numberOfRowsInSection: 1) == 2)
        #expect(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)) == false)
        #expect(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 1)))
        #expect(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 1, section: 1)))
    }

    @Test("Help sections and item lookup preserve the shipped mapping")
    func helpMapping() {
        let dataSource = HelpDataSource()
        let tableView = UITableView()
        let expectedTitles = [
            "Where to start",
            "What are the points for?",
            "Can I retake daily challenges?",
            "Where can I report mistakes?",
            "How can I take the tour again?",
            "How can I reset my data?",
            "About this app"
        ]
        let expectedActions = ["", "", "", "", "showTour", "resetProgress", ""]

        #expect(dataSource.numberOfSections(in: tableView) == expectedTitles.count)
        #expect(dataSource.items.map(\.title) == expectedTitles)
        #expect(dataSource.items.map(\.action) == expectedActions)

        for section in expectedTitles.indices {
            let item = dataSource.item(at: section)
            #expect(dataSource.tableView(tableView, numberOfRowsInSection: section) == 1)
            #expect(item.title == expectedTitles[section])
            #expect(item.action == expectedActions[section])
            #expect(item.text.isEmpty == false)
        }
    }
}
