//
//  LearnNavigationTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Learn lesson loading")
struct LearnNavigationTests {
    private var bundle: Bundle {
        .main
    }

    @Test("A selected lesson loads its native content and video")
    func lessonContent() throws {
        let lesson = try Lesson(title: "Variables", bundle: bundle)

        #expect(lesson.id == "variables")
        #expect(lesson.videoURL != nil)
        #expect(lesson.content.blocks.count == 9)
        #expect(lesson.content.blocks[4] == .code("var str = \"Hello, playground\""))
        #expect(lesson.content.blocks[7] == .code("str = \"Goodbye\""))
    }

    @Test("The final lesson has no video")
    func lessonWithoutVideo() throws {
        let lesson = try Lesson(title: "Where now?", bundle: bundle)

        #expect(lesson.id == "where-now")
        #expect(lesson.videoURL == nil)
        #expect(lesson.content.blocks.count == 6)

        guard case .bullets(let items) = lesson.content.blocks[3] else {
            Issue.record("Where now? should contain its native unordered list.")
            return
        }

        #expect(items.count == 4)
        let firstItem = try #require(items.first)
        #expect(firstItem.contains("[here](https://www.hackingwithswift.com/read)"))
    }

    @Test("Lesson blocks require exactly one supported key")
    func lessonBlockSchema() throws {
        let validData = Data(#"{"text":"Hello"}"#.utf8)
        let block = try JSONDecoder().decode(LessonBlock.self, from: validData)
        #expect(block == .text("Hello"))

        let invalidJSON = [
            #"{}"#,
            #"{"unknown":"Hello"}"#,
            #"{"text":"Hello","code":"print(Hello)"}"#,
            #"{"text":"Hello","unknown":"Extra"}"#
        ]

        for json in invalidJSON {
            #expect(throws: DecodingError.self) {
                try JSONDecoder().decode(LessonBlock.self, from: Data(json.utf8))
            }
        }
    }
}
