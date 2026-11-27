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
    @State private var presented = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            if let record = user.optionalReview, !record.isDue(at: timeline.date) {
                VStack(alignment: .leading) {
                    Text(record.outcome.summary)
                    Text("Review again \(record.nextReview.formatted(date: .abbreviated, time: .shortened)).")
                }
            } else {
                Button("Review optional values") { presented = true }
            }
        }
        .sheet(isPresented: $presented) {
            NavigationStack { OptionalReviewExercise(user: user) }
        }
    }
}

private struct OptionalReviewExercise: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    @State private var usedHint = false
    @State private var explanation: String?

    private let examples = [
        ("let title: String? = nil", "title ?? \"Mix\"", ["nil", "Mix", "(empty string)"], "Mix"),
        ("let name: String? = \"\"", "name ?? \"Guest\"", ["Guest", "(empty string)", "nil"], "(empty string)"),
        ("let city: String? = \"Lima\"", "city ?? \"Oslo\"", ["Oslo", "nil", "Lima"], "Lima")
    ]

    var body: some View {
        let index = ((user.optionalReview?.exampleIndex ?? -1) % examples.count + 1) % examples.count
        let example = examples[index]
        Form {
            if let explanation {
                Text(explanation)
                if let record = user.optionalReview { Text(record.outcome.summary) }
                Button("Done") { dismiss() }
            } else {
                Section("What value does Swift produce?") {
                    Text("\(example.0)\n\(example.1)").font(.body.monospaced())
                }
                Section("Answer") {
                    ForEach(example.2, id: \.self) { choice in
                        Button(choice) {
                            let correctOutcome: OptionalReviewOutcome = usedHint ? .assisted : .independent
                            user.recordOptionalReview(outcome: choice == example.3 ? correctOutcome : .missed, at: .now)
                            explanation = "\(example.1) produces \(example.3). Only nil uses the fallback."
                        }
                    }
                }
                Section {
                    if usedHint {
                        Text("The fallback is used only when the optional contains nil.")
                    } else {
                        Button("Show hint") { usedHint = true }
                    }
                }
            }
        }
        .navigationTitle("Review optional values")
    }
}
