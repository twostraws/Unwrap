//
//  RandomSourceTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@Suite("Injected random source")
struct RandomSourceTests {
    @Test("Matching seeds generate matching bounded values")
    func deterministicValues() {
        let first = SeededRandomSource(seed: 42)
        let second = SeededRandomSource(seed: 42)

        let firstValues = (0..<20).map { _ in first.nextInt(in: 3...9) }
        let secondValues = (0..<20).map { _ in second.nextInt(in: 3...9) }

        #expect(firstValues == secondValues)
        #expect(firstValues.allSatisfy { (3...9).contains($0) })
    }

    @Test("Seeded shuffling preserves every value and is reproducible")
    func deterministicShuffle() {
        let first = SeededRandomSource(seed: 123)
        let second = SeededRandomSource(seed: 123)
        let input = Array(0..<20)
        let firstResult = first.shuffled(input)
        let secondResult = second.shuffled(input)

        #expect(firstResult == secondResult)
        #expect(firstResult != input)
        #expect(firstResult.sorted() == input)
    }

    @Test("Choosing from an empty collection is safe")
    func emptyChoice() {
        let random = SeededRandomSource(seed: 1)
        let result: Int? = random.element(from: [])

        #expect(result == nil)
    }

    @Test("Every closed Int range is overflow-safe")
    func wideIntegerRanges() {
        let random = SeededRandomSource(seed: 9)
        let nonnegative = (0..<100).map { _ in random.nextInt(in: 0...Int.max) }
        let fullWidth = (0..<100).map { _ in random.nextInt(in: Int.min...Int.max) }

        #expect(nonnegative.allSatisfy { $0 >= 0 })
        #expect(fullWidth.count == 100)
        #expect(random.nextInt(in: Int.min...Int.min) == Int.min)
        #expect(random.nextInt(in: Int.max...Int.max) == Int.max)
    }
}
