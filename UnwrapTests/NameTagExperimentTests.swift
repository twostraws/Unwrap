import Testing
@testable import Unwrap

struct NameTagExperimentTests {
    @Test func missingAndBlankNames() {
        #expect(BadgeInput.missing.displayedName(fallback: "Visitor") == "Visitor")
        #expect(BadgeInput.blank.displayedName(fallback: "Visitor").isEmpty)
        #expect(BadgeInput.name.displayedName(fallback: "Visitor") == "Fern")
    }
}
