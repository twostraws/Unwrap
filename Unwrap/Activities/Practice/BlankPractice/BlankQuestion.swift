import Foundation
import FoundationModels

@Generable
enum BlankTopic: String, CaseIterable {
    case arithmetic, collections, optionals

    var title: String { rawValue.capitalized }
}

@Generable
enum BlankOperation: String, CaseIterable {
    case add, multiply, remainder, subtract

    var token: String {
        switch self {
        case .add: "+"
        case .multiply: "*"
        case .remainder: "%"
        case .subtract: "-"
        }
    }

    func result(_ lhs: Int, _ rhs: Int) -> Int {
        switch self {
        case .add: lhs + rhs
        case .multiply: lhs * rhs
        case .remainder: lhs % rhs
        case .subtract: lhs - rhs
        }
    }

    var clue: String {
        switch self {
        case .add: "Combine the two counts."
        case .multiply: "Think about equal groups."
        case .remainder: "What remains after making whole groups?"
        case .subtract: "Find the difference between the counts."
        }
    }
}

@Generable
struct BlankRecipe {
    @Guide(description: "One plural English noun. For example: shells.")
    var objects: String
    var operation: BlankOperation
    @Guide(description: "Starting count", .range(8...30))
    var left: Int
    @Guide(description: "Second count", .range(2...7))
    var right: Int
}

nonisolated struct BlankQuestion {
    let recipe: BlankRecipe
    let topic: BlankTopic

    init?(_ recipe: BlankRecipe, topic: BlankTopic) {
        guard (8...30).contains(recipe.left), (2...7).contains(recipe.right),
              (1...30).contains(recipe.objects.count),
              recipe.objects.allSatisfy({ $0.isLetter || $0 == " " }),
              recipe.objects.contains(where: \.isLetter) else { return nil }

        // Keep the model's operands when possible. An ambiguous answer should
        // never cost a learner a point. Increase the left operand until the outputs differ.
        var checked = recipe
        if topic == .collections { checked.right = max(3, checked.right) }
        while Set(BlankOperation.allCases.map({ $0.result(checked.left, checked.right) })).count < 4 {
            checked.left += 1
        }
        self.recipe = checked
        self.topic = topic
    }

    var tokens: [String] {
        switch topic {
        case .arithmetic: BlankOperation.allCases.map(\.token)
        case .collections: ["first", "last", "count"]
        case .optionals: ["??", "==", "!="]
        }
    }

    var expectedToken: String {
        switch topic {
        case .arithmetic: recipe.operation.token
        case .collections:
            switch recipe.operation {
            case .add: "count"
            case .remainder: "first"
            case .subtract, .multiply: "last"
            }
        case .optionals:
            switch recipe.operation {
            case .add, .multiply: "??"
            case .remainder: "=="
            case .subtract: "!="
            }
        }
    }

    var code: String {
        switch topic {
        case .arithmetic:
            "print(\(recipe.left) ___ \(recipe.right))"
        case .collections:
            "let items = [\(recipe.left), \(recipe.right)]\nprint(items.___" + (expectedToken == "count" ? ")" : " ?? 0)")
        case .optionals:
            "let count: Int? = nil\nprint(count ___ \(recipe.right))"
        }
    }

    var output: String {
        switch topic {
        case .arithmetic: String(recipe.operation.result(recipe.left, recipe.right))
        case .collections:
            switch expectedToken {
            case "first": String(recipe.left)
            case "last": String(recipe.right)
            default: "2"
            }
        case .optionals:
            switch expectedToken {
            case "==": "false"
            case "!=": "true"
            default: String(recipe.right)
            }
        }
    }

    var clue: String {
        switch topic {
        case .arithmetic: recipe.operation.clue
        case .collections: "Look at the position of each element, then count how many elements there are."
        case .optionals: "A comparison produces a Bool. A fallback produces an Int in this example."
        }
    }

    func accepts(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines) == expectedToken
    }

    func feedback(for text: String) -> String {
        let token = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard tokens.contains(token) else { return "Try one of these Swift tokens: " + tokens.joined(separator: ", ") + "." }
        switch topic {
        case .arithmetic:
            guard let choice = BlankOperation.allCases.first(where: { $0.token == token }) else { return clue }
            return "With \(token), Swift produces \(choice.result(recipe.left, recipe.right)). The target is \(output)."
        case .collections:
            if token == "count" { return "count gives the number of elements as an Int." }
            return "\(token) gives an optional element from the \(token == "first" ? "start" : "end") of the array."
        case .optionals:
            if token == "??" { return "The fallback produces \(recipe.right). The target is \(output)." }
            return "Comparing nil with a number using \(token) produces \(token == "==" ? "false" : "true")."
        }
    }

    static func authored(topic: BlankTopic, after previous: BlankOperation? = nil) -> BlankQuestion {
        let operations = BlankOperation.allCases
        let index = previous.flatMap { operations.firstIndex(of: $0) }.map { ($0 + 1) % operations.count } ?? 0
        return BlankQuestion(topic: topic, operation: operations[index], index: index)
    }

    private init(topic: BlankTopic, operation: BlankOperation, index: Int) {
        self.topic = topic
        recipe = BlankRecipe(objects: ["shells", "tickets", "stars", "coins"][index], operation: operation, left: 11 + index, right: 3)
    }
}
