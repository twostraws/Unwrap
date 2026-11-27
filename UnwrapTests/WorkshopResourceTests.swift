import Foundation
import Testing
@testable import Unwrap

struct WorkshopResourceTests {
    @Test(arguments: ["BadgeState", "BadgeStorage", "BadgeLoading", "BadgeChecks"])
    func sourceIsAvailableToLearners(name: String) throws {
        let data = try Bundle.main.data(named: name + ".txt")
        let source = try #require(String(data: data, encoding: .utf8))
        #expect(source.contains("import "))
    }
}
