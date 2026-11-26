//
//  DataSourceBehaviorTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Native catalog behavior", .serialized)
struct DataSourceBehaviorTests {
    @Test("Glossary entries are grouped and indexed alphabetically")
    func glossaryGrouping() {
        let index = GlossaryIndex(entries: [
            LearnGlossaryEntry(term: "closure", description: "A closure"),
            LearnGlossaryEntry(term: "Array", description: "An array"),
            LearnGlossaryEntry(term: "actor", description: "An actor"),
            LearnGlossaryEntry(term: "Zebra", description: "A zebra")
        ])

        #expect(index.sections.map(\.title) == ["A", "C", "Z"])
        #expect(index.sections[0].entries.map(\.term) == ["Array", "actor"])
        #expect(index.sections[1].entries.map(\.term) == ["closure"])
        #expect(index.sections[2].entries.map(\.term) == ["Zebra"])
        #expect(index.sections.flatMap(\.entries).count == 4)
    }

    @Test("Glossary search uses localized matching and restores all entries")
    func glossaryFiltering() {
        let index = GlossaryIndex(entries: [
            LearnGlossaryEntry(term: "Résumé", description: "A summary"),
            LearnGlossaryEntry(term: "Result", description: "A value"),
            LearnGlossaryEntry(term: "Closure", description: "A closure")
        ])

        let resumeResults = index.filtered(by: "  resume\n")
        let resultResults = index.filtered(by: "RESULT")
        let restoredResults = index.filtered(by: " \t ")
        let missingResults = index.filtered(by: "protocol")

        #expect(resumeResults.entries.map(\.term) == ["Résumé"])
        #expect(resumeResults.sections.map(\.title) == ["R"])
        #expect(resultResults.entries.map(\.term) == ["Result"])
        #expect(restoredResults == index)
        #expect(restoredResults.sections.map(\.title) == ["C", "R"])
        #expect(missingResults.entries.isEmpty)
        #expect(missingResults.sections.isEmpty)
    }

    @Test("Empty challenge history has no results")
    func emptyChallengeHistory() {
        let user = User()
        let model = ChallengesModel(user: user)

        #expect(model.history.isEmpty)
    }

    @Test("Challenge history preserves its saved order and deletes the selected result")
    func challengeHistory() throws {
        let user = User()
        user.dailyChallenges = [
            ChallengeResult(date: Date(timeIntervalSince1970: 1_000), score: 50),
            ChallengeResult(date: Date(timeIntervalSince1970: 3_000), score: 150),
            ChallengeResult(date: Date(timeIntervalSince1970: 2_000), score: 100)
        ]
        let model = ChallengesModel(user: user)
        let deleted = try #require(model.history.dropFirst().first)

        #expect(model.history.map(\.score) == [50, 150, 100])

        model.delete(deleted)

        #expect(model.history.map(\.score) == [50, 100])
    }
}
