import Testing
@testable import Unwrap

struct BlankQuestionTests {
    @Test func invalidRecipes() {
        #expect(BlankQuestion(.init(objects: "shells", operation: .remainder, left: 9, right: 0), topic: .arithmetic) == nil)
        #expect(BlankQuestion(.init(objects: "x\ny", operation: .add, left: 9, right: 2), topic: .arithmetic) == nil)
    }

    @Test func arithmeticRecipesHaveUniqueAnswers() throws {
        for left in 8...30 {
            for right in 2...7 {
                let question = try #require(BlankQuestion(.init(objects: "tickets", operation: .subtract, left: left, right: right), topic: .arithmetic))
                let outputs = BlankOperation.allCases.map { $0.result(question.recipe.left, right) }
                #expect(Set(outputs).count == 4)
                #expect(question.output == String(question.recipe.left - right))
            }
        }
    }

    @Test func groundedCoaching() throws {
        let question = try #require(BlankQuestion(
            .init(objects: "shells", operation: .subtract, left: 12, right: 3), topic: .arithmetic
        ))
        #expect(question.accepts("-"))
        #expect(!question.accepts("+"))
        #expect(HintStrategy.compareAttempt.render(question: question, attempted: "+").contains("15"))
        #expect(HintStrategy.reasonAboutResult.render(question: question, attempted: "+").contains("9"))
        #expect(HintStrategy.compareAttempt.render(question: question, attempted: "random text") == question.clue)
    }

    @Test func collectionAndOptionalAnswers() throws {
        for operation in BlankOperation.allCases {
            let recipe = BlankRecipe(objects: "seeds", operation: operation, left: 13, right: 2)
            let array = try #require(BlankQuestion(recipe, topic: .collections))
            let items = [array.recipe.left, array.recipe.right]
            let values = ["count": items.count, "first": items.first ?? 0, "last": items.last ?? 0]
            #expect(values.filter { String($0.value) == array.output }.map(\.key) == [array.expectedToken])
            let missing = try #require(BlankQuestion(recipe, topic: .optionals))
            let count: Int? = nil
            let results = ["??": String(count ?? recipe.right), "==": String(count == recipe.right), "!=": String(count != recipe.right)]
            #expect(results[missing.expectedToken] == missing.output)
        }
    }

    @Test(arguments: BlankTopic.allCases)
    func authoredQuestions(topic: BlankTopic) {
        for operation in BlankOperation.allCases {
            let question = BlankQuestion.authored(topic: topic, after: operation)
            #expect(question.recipe.operation != operation)
            #expect(question.tokens.filter { question.accepts($0) }.count == 1)
            #expect(question.accepts(" \(question.expectedToken) "))
            #expect(!question.accepts("?"))
            #expect(question.code.components(separatedBy: "___").count == 2)
        }
    }
}
