//
//  ContentIntegrityTests.swift
//  UnwrapTests
//

import Foundation
import Testing
import UIKit
@testable import Unwrap

/// Verifies that the content shipped with the app is complete and internally consistent.
@Suite("Shipped content integrity")
struct ContentIntegrityTests {
    @Test("Tour content is complete")
    func tourContent() throws {
        let items = try decode([TourItem].self, from: "Tour.json")

        #expect(items.count == 6)
        #expect(allUnique(items.map(\.title)))
        #expect(allUnique(items.map(\.image)))

        for item in items {
            #expect(!item.title.isEmpty)
            #expect(!item.text.isEmpty)
            #expect(!item.image.isEmpty)
            #expect(UIImage(named: item.image, in: Bundle.main, compatibleWith: nil) != nil)
        }
    }

    @Test("Help content has only supported actions")
    func helpContent() throws {
        let items = try decode([HelpItem].self, from: "Help.json")
        let supportedActions: Set<String> = ["", "showTour", "resetProgress"]

        #expect(items.count == 7)
        #expect(allUnique(items.map(\.title)))

        for item in items {
            #expect(!item.title.isEmpty)
            #expect(!item.text.isEmpty)
            #expect(supportedActions.contains(item.action))
        }
    }

    @Test("Glossary entries are complete and unique")
    func glossaryContent() throws {
        let entries = try decode([GlossaryEntry].self, from: "glossary.json")
        let normalizedTerms = entries.map { $0.term.lowercased() }

        #expect(entries.count == 144)
        #expect(allUnique(normalizedTerms))

        for entry in entries {
            #expect(!entry.term.isEmpty)
            #expect(!entry.description.isEmpty)
        }
    }

    @Test("Every chapter section has its media and a valid review")
    func chapterContent() throws {
        let chapters = try decode([Chapter].self, from: "Chapters.json")
        let chapterNames = chapters.map(\.name)
        let sections = chapters.flatMap(\.sections)
        let sectionNames = sections.map(\.bundleName)

        #expect(chapters.count == 11)
        #expect(sections.count == 99)
        #expect(allUnique(chapterNames))
        #expect(allUnique(sectionNames))

        for chapter in chapters {
            #expect(!chapter.name.isEmpty)
            #expect(!chapter.sections.isEmpty)

            for section in chapter.sections {
                let bundleName = section.bundleName

                #expect(resourceExists(named: "\(bundleName).html"))
                #expect(resourceExists(named: "\(bundleName).json"))
                #expect(resourceExists(named: "\(bundleName).png"))
                #expect(resourceExists(named: "\(bundleName).mp4") == (bundleName != "where-now"))

                let review = try decode(StudyReview.self, from: "\(bundleName).json")
                validate(review: review, expectedTitle: section)
            }
        }
    }

    @Test("Practice question banks satisfy their runtime assumptions")
    func practiceContent() throws {
        try validateFreeCoding()
        try validatePredictTheOutput()
        try validateRearrangeTheLines()
        try validateTapToCode()
        try validateSpotTheError()
    }

    @Test("Badge rules point to valid criteria and assets")
    func badgeContent() throws {
        let badges = try decode([Badge].self, from: "Badges.json")
        let chapters = try decode([Chapter].self, from: "Chapters.json")
        let chapterValues = Set(chapters.map { $0.name.bundleName })
        let practiceValues: Set<String> = [
            "free-coding",
            "predict-the-output",
            "rearrange-the-lines",
            "spot-the-error",
            "tap-to-code",
            "type-practice"
        ]
        let numericCriteria: Set<String> = ["challenge", "news", "share", "streak"]
        let supportedCriteria = numericCriteria.union(["practice", "read"])

        #expect(badges.count == 25)
        #expect(allUnique(badges.map(\.name)))
        #expect(allUnique(badges.map(\.filename)))
        #expect(Set(badges.map(\.criterion)) == supportedCriteria)

        for badge in badges {
            #expect(!badge.name.isEmpty)
            #expect(!badge.description.isEmpty)
            #expect(!badge.color.isEmpty)
            #expect(!badge.value.isEmpty)
            #expect(supportedCriteria.contains(badge.criterion))
            #expect(UIColor(named: badge.color, in: Bundle.main, compatibleWith: nil) != nil)
            #expect(UIImage(named: "Badge-\(badge.filename)", in: Bundle.main, compatibleWith: nil) != nil)

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

    private func validate(review: StudyReview, expectedTitle: String) {
        let supportedReviewTypes: Set<String> = ["multipleSelection", "singleSelection"]
        let correctAnswers = Set(review.correct.map(\.answer))
        let wrongAnswers = Set(review.wrong.map(\.answer))

        #expect(review.title == expectedTitle)
        #expect(!review.question.isEmpty)
        #expect(!review.hint.isEmpty)
        #expect(supportedReviewTypes.contains(review.reviewType))
        #expect(review.correct.count == 6)
        #expect(review.wrong.count == 6)
        #expect(correctAnswers.count == review.correct.count)
        #expect(wrongAnswers.count == review.wrong.count)
        #expect(correctAnswers.isDisjoint(with: wrongAnswers))

        for answer in review.correct + review.wrong {
            #expect(!answer.answer.isEmpty)
            #expect(!answer.reason.isEmpty)
        }
    }

    private func validateFreeCoding() throws {
        let questions = try decode([FreeCodingQuestion].self, from: "FreeCoding.json")

        #expect(questions.count == 11)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(!question.question.isEmpty)
            #expect(!question.hint.isEmpty)
            #expect(!question.answers.isEmpty)
            #expect(allUnique(question.answers))
            #expect(question.answers.allSatisfy { !$0.isEmpty })
        }
    }

    private func validatePredictTheOutput() throws {
        let questions = try decode([PredictTheOutputQuestion].self, from: "PredictTheOutput.json")
        let supportedChecks: Set<String> = ["<", "<=", "==", "!=", ">=", ">"]

        #expect(questions.count == 10)
        #expect(allUnique(questions.map(\.code)))

        for question in questions {
            #expect(!question.code.isEmpty)
            #expect(!question.answers.isEmpty)
            #expect(question.answers.filter { $0.conditions == nil }.count == 1)

            for answer in question.answers {
                #expect(!answer.text.isEmpty)

                if let conditions = answer.conditions {
                    #expect(!conditions.isEmpty)

                    for condition in conditions {
                        let isOperatorPlaceholder = condition.check.hasPrefix("OPERATOR_")
                            && Int(condition.check.dropFirst(9)) != nil

                        #expect(!condition.left.isEmpty)
                        #expect(!condition.right.isEmpty)
                        #expect(supportedChecks.contains(condition.check) || isOperatorPlaceholder)
                    }
                }
            }
        }
    }

    private func validateRearrangeTheLines() throws {
        let questions = try decode([RearrangeTheLinesQuestion].self, from: "RearrangeTheLines.json")

        #expect(questions.count == 31)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(!question.question.isEmpty)
            #expect(!question.hint.isEmpty)
            #expect(question.code.lines.count >= 2)
            #expect(question.code.lines.allSatisfy { !$0.isEmpty })
        }
    }

    private func validateTapToCode() throws {
        let questions = try decode([TapToCodeQuestion].self, from: "TapToCode.json")

        #expect(questions.count == 19)
        #expect(allUnique(questions.map(\.question)))

        for question in questions {
            #expect(!question.question.isEmpty)
            #expect(!question.components.isEmpty)
            #expect(question.components.allSatisfy { !$0.isEmpty })
        }
    }

    private func validateSpotTheError() throws {
        let questions = try decode([SpotTheErrorQuestion].self, from: "SpotTheError.json")

        #expect(questions.count == 12)
        #expect(allUnique(questions.map(\.file)))

        for question in questions {
            let template = try loadString(named: "SpotTheError-\(question.file).txt")

            #expect(question.inputMinimum <= question.inputMaximum)
            #expect(!question.replacements.isEmpty)

            for replacement in question.replacements {
                #expect(!replacement.name.isEmpty)
                #expect(!replacement.values.isEmpty)
                #expect(allUnique(replacement.values))
                #expect(replacement.values.allSatisfy { !$0.isEmpty })
                #expect(template.contains(replacement.name))
            }
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = try #require(
            Bundle.main.url(forResource: filename, withExtension: nil),
            "Missing bundled resource: \(filename)"
        )
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    private func loadString(named filename: String) throws -> String {
        let url = try #require(
            Bundle.main.url(forResource: filename, withExtension: nil),
            "Missing bundled resource: \(filename)"
        )
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func resourceExists(named filename: String) -> Bool {
        Bundle.main.url(forResource: filename, withExtension: nil) != nil
    }

    private func allUnique<Element: Hashable>(_ elements: [Element]) -> Bool {
        Set(elements).count == elements.count
    }
}
