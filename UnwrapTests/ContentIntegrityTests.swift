//
//  ContentIntegrityTests.swift
//  UnwrapTests
//

import Foundation
import SwiftUI
import Testing
@testable import Unwrap

/// Verifies that content shipped with the app remains complete and internally consistent.
@Suite("Shipped content integrity")
struct ContentIntegrityTests {
    private var bundle: Bundle {
        .main
    }

    @Test("Tour content and source assets are complete")
    func tourContent() throws {
        let items = try bundle.decode([TourItem].self, from: "Tour.json")
        let expectedImages = ["Tour1", "Tour2", "Tour3", "Tour4", "Tour5"]

        #expect(items.count == 5)
        #expect(items.map(\.image) == expectedImages)
        #expect(allUnique(items.map(\.title)))
        #expect(allUnique(items.map(\.image)))

        let imageResources: [ImageResource] = [.tour1, .tour2, .tour3, .tour4, .tour5]
        #expect(imageResources.count == expectedImages.count)

        for item in items {
            #expect(item.title.isEmpty == false)
            #expect(item.text.isEmpty == false)
        }
    }

    @Test("Help content preserves its shipped order and supported actions")
    func helpContent() throws {
        let items = try bundle.decode([HelpItem].self, from: "Help.json")
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

        #expect(items.map(\.title) == expectedTitles)
        #expect(items.map(\.action) == expectedActions)
        #expect(allUnique(items.map(\.title)))
        #expect(items.allSatisfy { $0.text.isEmpty == false })
    }

    @Test("Every Learn topic loads its native content, review, and video")
    func learnContent() throws {
        let titles = Unwrap.chapters.flatMap(\.sections)

        #expect(Unwrap.chapters.count == 11)
        #expect(titles.count == 99)
        #expect(allUnique(titles))

        for title in titles {
            let lesson = try Lesson(title: title, bundle: bundle)

            #expect(lesson.id == title.bundleName)
            #expect(lesson.content.blocks.isEmpty == false)
            #expect(lesson.review.title == title)
            #expect(lesson.review.question.isEmpty == false)
            #expect(lesson.review.hint.isEmpty == false)
            #expect(lesson.review.correct.count == 6)
            #expect(lesson.review.wrong.count == 6)
            for block in lesson.content.blocks {
                switch block {
                case .text(let markdown), .code(let markdown):
                    #expect(markdown.isEmpty == false)
                case .bullets(let items), .numbered(let items):
                    #expect(items.isEmpty == false)
                    #expect(items.allSatisfy { $0.isEmpty == false })
                }
            }

            if lesson.id == "where-now" {
                #expect(lesson.videoURL == nil)
            } else {
                let videoURL = try #require(lesson.videoURL)
                #expect(videoURL.isFileURL)
                #expect(try Data(contentsOf: videoURL).isEmpty == false)
            }
        }
    }

    @Test("The shipped glossary is complete and alphabetically indexed")
    func glossaryContent() throws {
        let entries = try bundle.decode([LearnGlossaryEntry].self, from: "glossary.json")
        let index = GlossaryIndex(entries: entries)
        let normalizedTerms = entries.map { $0.term.lowercased() }

        #expect(entries.count == 144)
        #expect(allUnique(normalizedTerms))
        #expect(entries.allSatisfy {
            $0.term.isEmpty == false && $0.description.isEmpty == false
        })
        #expect(index.sections.flatMap(\.entries).count == entries.count)
        #expect(index.sections.map(\.title) == index.sections.map(\.title).sorted())
    }

    /// The glossary preserves file order within each letter, so the bundled JSON must be sorted.
    @Test("Glossary entries are alphabetical within each letter")
    func glossaryOrder() throws {
        let entries = try bundle.decode([LearnGlossaryEntry].self, from: "glossary.json")

        for section in GlossaryIndex(entries: entries).sections {
            let terms = section.entries.map(\.term)
            let sortedTerms = terms.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

            #expect(terms == sortedTerms, "Section \(section.title) is out of order.")
        }
    }

    @Test("Practice question banks satisfy every runtime assumption")
    func practiceContent() throws {
        try validateFreeCoding(
            bundle.decode([FreeCodingContent].self, from: "FreeCoding.json")
        )
        try validatePredictOutput(
            bundle.decode([PredictOutputContent].self, from: "PredictTheOutput.json")
        )
        try validateRearrangeLines(
            bundle.decode([RearrangeLinesContent].self, from: "RearrangeTheLines.json")
        )
        try validateTapToCode(
            bundle.decode([TapToCodeContent].self, from: "TapToCode.json")
        )
        try validateSpotError(
            bundle.decode([SpotErrorContent].self, from: "SpotTheError.json")
        )
        try validatePracticeReviews()
    }

    @Test("Badge rules point to valid criteria, chapter IDs, colors, and artwork")
    func badgeContent() throws {
        let badges = try bundle.decode([Badge].self, from: "Badges.json")
        let chapterValues = Set(Unwrap.chapters.map { $0.name.bundleName })
        let practiceValues: Set<String> = [
            "free-coding",
            "predict-the-output",
            "rearrange-the-lines",
            "spot-the-error",
            "tap-to-code",
            "type-practice"
        ]
        let numericCriteria: Set<String> = ["challenge", "news", "streak"]
        let supportedCriteria = numericCriteria.union(["practice", "read"])
        let expectedColors: Set<String> = [
            "Badge-Challenge", "Badge-Chapter", "Badge-Misc", "Badge-Practice", "Badge-Streak"
        ]
        let colorResources: [ColorResource] = [
            .badgeChallenge, .badgeChapter, .badgeMisc, .badgePractice, .badgeStreak
        ]

        #expect(badges.count == 24)
        #expect(allUnique(badges.map(\.name)))
        #expect(Set(badges.map(\.criterion)) == supportedCriteria)
        #expect(Set(badges.map(\.color)) == expectedColors)
        #expect(colorResources.count == expectedColors.count)

        for badge in badges {
            #expect(badge.name.isEmpty == false)
            #expect(badge.description.isEmpty == false)
            #expect(badge.color.isEmpty == false)
            #expect(badge.value.isEmpty == false)
            #expect(badge.symbolName.isEmpty == false)
            #expect(supportedCriteria.contains(badge.criterion))
            #expect(expectedColors.contains(badge.color))

            switch badge.criterion {
            case "read":
                #expect(chapterValues.contains(badge.value))
            case "practice":
                #expect(practiceValues.contains(badge.value))
            default:
                let value = Int(badge.value)
                #expect(value != nil)
                #expect((value ?? 0) > 0)
            }
        }
    }

    private func validateFreeCoding(_ questions: [FreeCodingContent]) throws {
        #expect(questions.count == 11)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(question.question.isEmpty == false)
            #expect(question.hint.isEmpty == false)
            #expect(question.answers.isEmpty == false)
            #expect(allUnique(question.answers))
            #expect(question.answers.allSatisfy { $0.isEmpty == false })
        }
    }

    private func validatePredictOutput(_ questions: [PredictOutputContent]) throws {
        let supportedChecks: Set<String> = ["<", "<=", "==", "!=", ">=", ">"]

        #expect(questions.count == 10)
        #expect(allUnique(questions.map(\.code)))

        for question in questions {
            #expect(question.code.isEmpty == false)
            #expect(question.answers.isEmpty == false)
            #expect(question.answers.filter { $0.conditions == nil }.count == 1)

            for answer in question.answers {
                #expect(answer.text.isEmpty == false)

                for condition in answer.conditions ?? [] {
                    let isOperatorPlaceholder = condition.check.hasPrefix("OPERATOR_")
                        && Int(condition.check.dropFirst(9)) != nil

                    #expect(condition.left.isEmpty == false)
                    #expect(condition.right.isEmpty == false)
                    #expect(supportedChecks.contains(condition.check) || isOperatorPlaceholder)
                }
            }
        }
    }

    private func validateRearrangeLines(_ questions: [RearrangeLinesContent]) throws {
        #expect(questions.count == 31)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(question.question.isEmpty == false)
            #expect(question.hint.isEmpty == false)
            #expect(question.code.lines.count >= 2)
            #expect(question.code.lines.allSatisfy { $0.isEmpty == false })
        }
    }

    private func validateTapToCode(_ questions: [TapToCodeContent]) throws {
        #expect(questions.count == 19)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(question.question.isEmpty == false)
            #expect(question.components.isEmpty == false)
            #expect(question.components.allSatisfy { $0.isEmpty == false })
        }
    }

    private func validateSpotError(_ questions: [SpotErrorContent]) throws {
        #expect(questions.count == 12)
        #expect(allUnique(questions.map(\.file)))

        for question in questions {
            let template = try bundle
                .text(named: "SpotTheError-\(question.file).txt")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            #expect(question.inputMinimum <= question.inputMaximum)
            #expect(question.replacements.isEmpty == false)
            #expect(template.isEmpty == false)

            for replacement in question.replacements {
                #expect(replacement.name.isEmpty == false)
                #expect(replacement.values.isEmpty == false)
                #expect(allUnique(replacement.values))
                #expect(replacement.values.allSatisfy { $0.isEmpty == false })
                #expect(template.contains(replacement.name))
            }

            // One generated error lowercases the function name at its call site, which
            // only looks like a mistake when the real name contains a capital letter.
            let functionNames = question.replacements.first { $0.name == "FUNCTION_NAME" }?.values ?? []
            #expect(functionNames.isEmpty == false)
            #expect(functionNames.allSatisfy { $0 != $0.lowercased() })
        }
    }

    private func validatePracticeReviews() throws {
        let sectionIDs = Unwrap.chapters.flatMap(\.sections).map(\.bundleName)

        #expect(sectionIDs.count == 99)
        #expect(allUnique(sectionIDs))

        for sectionID in sectionIDs {
            let review = try bundle.decode(ReviewContent.self, from: "\(sectionID).json")

            #expect(review.title.isEmpty == false)
            #expect(review.question.isEmpty == false)
            #expect(review.hint.isEmpty == false)
            #expect([ReviewKind.singleSelection, .multipleSelection].contains(review.kind))
            #expect(review.correct.count == 6)
            #expect(review.wrong.count == 6)
        }
    }

    private func allUnique<Element: Hashable>(_ elements: [Element]) -> Bool {
        Set(elements).count == elements.count
    }
}
