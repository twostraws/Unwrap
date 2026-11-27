import SwiftUI

enum OptionalReviewOutcome: String, Codable {
    case independent, assisted, missed

    var summary: String {
        switch self {
        case .independent: "Solved independently"
        case .assisted: "Solved with a hint"
        case .missed: "Scheduled for another try"
        }
    }
}

struct OptionalReviewRecord: Codable, Equatable {
    let nextReview: Date
    let outcome: OptionalReviewOutcome
    let exampleIndex: Int

    init(previous: Self?, outcome: OptionalReviewOutcome, date: Date) {
        self.outcome = outcome
        exampleIndex = ((previous?.exampleIndex ?? -1) % 3 + 1) % 3
        let days = outcome == .independent ? 7 : 1
        nextReview = Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }

    func isDue(at date: Date) -> Bool {
        date >= nextReview
    }
}

struct OptionalReviewView: View {
    let user: User
    @State private var usedHint = false
    @State private var lastExplanation: String?
    private let examples = [
        ("let title: String? = nil", "title ?? \"Mix\"", "Mix"),
        ("let name: String? = \"\"", "name ?? \"Guest\"", "(empty string)"),
        ("let city: String? = \"Lima\"", "city ?? \"Oslo\"", "Lima")
    ]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            if let record = user.optionalReview, !record.isDue(at: timeline.date) {
                if let lastExplanation { Text(lastExplanation) }
                Text(record.outcome.summary)
                Text("Review again \(record.nextReview.formatted(date: .abbreviated, time: .shortened)).")
            } else {
                let index = ((user.optionalReview?.exampleIndex ?? -1) % examples.count + 1) % examples.count
                let example = examples[index]
                VStack(alignment: .leading, spacing: 12) {
                    Text("What value does Swift produce?")
                    Text("\(example.0)\n\(example.1)").font(.body.monospaced())
                    ForEach(choices(at: index), id: \.self) { choice in
                        Button(choice) {
                            lastExplanation = "\(example.1) produces \(example.2). Only nil uses the fallback."
                            let correctOutcome: OptionalReviewOutcome = usedHint ? .assisted : .independent
                            user.recordOptionalReview(outcome: choice == example.2 ? correctOutcome : .missed, at: .now)
                            usedHint = false
                        }
                        .buttonStyle(.bordered)
                    }
                    if usedHint {
                        Text("The fallback is used only when the optional contains nil.")
                    } else {
                        Button("Show hint") { usedHint = true }.buttonStyle(.borderless)
                    }
                }
            }
        }
    }

    private func choices(at index: Int) -> [String] {
        switch index {
        case 0: ["nil", "Mix", "(empty string)"]
        case 1: ["Guest", "(empty string)", "nil"]
        default: ["Oslo", "nil", "Lima"]
        }
    }
}
