//
//  GlossaryEntryView.swift
//  Unwrap
//

import SwiftUI

struct GlossaryEntryView: View {
    let entry: LearnGlossaryEntry
    let searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(highlightedTerm)

            MarkdownText(markdown: entry.description)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }

    private var highlightedTerm: AttributedString {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var result = AttributedString(entry.term)
        result.font = .body.bold()

        guard query.isEmpty == false,
              let stringRange = entry.term.localizedStandardRange(of: query),
              let range = Range(stringRange, in: result) else {
            return result
        }

        result[range].foregroundColor = .yellow
        result[range].font = .body.weight(.heavy)
        return result
    }
}
