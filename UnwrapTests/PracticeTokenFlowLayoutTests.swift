//
//  PracticeTokenFlowLayoutTests.swift
//  UnwrapTests
//

import CoreGraphics
import Testing
@testable import Unwrap

@Suite("Practice token flow layout")
struct PracticeTokenFlowLayoutTests {
    @Test("An oversized token is constrained to the available width")
    func oversizedToken() throws {
        let frames = PracticeTokenFlowLayout.frames(
            for: [CGSize(width: 300, height: 44)],
            width: 120,
            spacing: 8
        )
        let frame = try #require(frames.first)

        #expect(frame.width == 120)
        #expect(frame.maxX == 120)
    }

    @Test("A following token wraps after a width-constrained token")
    func followingTokenWraps() throws {
        let frames = PracticeTokenFlowLayout.frames(
            for: [CGSize(width: 300, height: 60), CGSize(width: 40, height: 20)],
            width: 120,
            spacing: 8
        )
        let firstFrame = try #require(frames.first)
        let lastFrame = try #require(frames.last)

        #expect(frames.count == 2)
        #expect(firstFrame.width == 120)
        #expect(lastFrame.minX == 0)
        #expect(lastFrame.minY == 68)
    }

    @Test("Tokens share a row while they fit, including an exact fit")
    func singleRow() {
        let frames = PracticeTokenFlowLayout.frames(
            for: [CGSize(width: 50, height: 30), CGSize(width: 62, height: 30)],
            width: 120,
            spacing: 8
        )

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 50, height: 30),
            CGRect(x: 58, y: 0, width: 62, height: 30)
        ])
    }

    @Test("A token that would overflow starts a new row below the tallest token above it")
    func wrappingUsesTallestToken() {
        let frames = PracticeTokenFlowLayout.frames(
            for: [
                CGSize(width: 50, height: 20),
                CGSize(width: 50, height: 44),
                CGSize(width: 50, height: 20),
                CGSize(width: 50, height: 20)
            ],
            width: 120,
            spacing: 8
        )

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 50, height: 20),
            CGRect(x: 58, y: 0, width: 50, height: 44),
            CGRect(x: 0, y: 52, width: 50, height: 20),
            CGRect(x: 58, y: 52, width: 50, height: 20)
        ])
    }

    @Test("Unlimited width keeps every token on one row at its natural size")
    func unlimitedWidth() {
        let sizes = [CGSize(width: 300, height: 20), CGSize(width: 400, height: 20), CGSize(width: 500, height: 20)]
        let frames = PracticeTokenFlowLayout.frames(for: sizes, width: .infinity, spacing: 10)

        #expect(frames.map(\.minX) == [0, 310, 720])
        #expect(frames.map(\.size) == sizes)
        #expect(frames.allSatisfy { $0.minY == 0 })
    }

    @Test("Frames never overlap and never extend past the available width", arguments: 0..<25)
    func framesStayInBounds(seed: Int) {
        let random = SeededRandomSource(seed: UInt64(seed))
        let width = Double(random.nextInt(in: 80...400))
        let sizes = (0..<random.nextInt(in: 1...20)).map { _ in
            CGSize(width: Double(random.nextInt(in: 10...500)), height: Double(random.nextInt(in: 10...60)))
        }
        let frames = PracticeTokenFlowLayout.frames(for: sizes, width: width, spacing: 8)

        #expect(frames.count == sizes.count)

        for (index, frame) in frames.enumerated() {
            #expect(frame.minX >= 0)
            #expect(frame.maxX <= width)
            #expect(frame.height == sizes[index].height)
            #expect(frames[..<index].allSatisfy { $0.intersects(frame) == false })
        }
    }

    @Test("No tokens produce no frames")
    func emptyInput() {
        #expect(PracticeTokenFlowLayout.frames(for: [], width: 120, spacing: 8).isEmpty)
    }
}
