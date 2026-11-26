import Foundation
import Testing
@testable import Unwrap

struct FreeCodingEqualityTests {
    @Test("Case-insensitive equality accepts either operand order and requires both arguments", arguments: [
        ("lhs.lowercased() == rhs.lowercased()", true),
        ("rhs.lowercased() == lhs.lowercased()", true),
        ("rhs.uppercased() == lhs.uppercased()", true),
        ("rhs.lowercased() == rhs.lowercased()", false),
        ("rhs.lowercased() != lhs.lowercased()", false)
    ])
    func caseInsensitiveEquality(expression: String, expected: Bool) throws {
        let bank = try Bundle.main.decode([FreeCodingContent].self, from: "FreeCoding.json")
        let question = try #require(bank.first { $0.question.contains("regardless of what letter case") })
        let result = FreeCodingEvaluator().evaluate(
            answer: "func same(_ lhs: String, _ rhs: String) -> Bool { \(expression) }",
            startingCode: question.startingCode,
            acceptedAnswers: question.answers
        )
        #expect(result.isCorrect == expected)
    }
}
