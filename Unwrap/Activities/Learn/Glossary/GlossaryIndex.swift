//
//  GlossaryIndex.swift
//  Unwrap
//

import Foundation

struct GlossaryIndex: Equatable {
    let entries: [LearnGlossaryEntry]

    var sections: [LearnGlossarySection] {
        let groupedEntries = Dictionary(grouping: entries) { entry in
            String(entry.term.prefix(1)).uppercased()
        }

        return groupedEntries.keys
            .sorted()
            .map { title in
                LearnGlossarySection(title: title, entries: groupedEntries[title, default: []])
            }
    }

    func filtered(by query: String) -> GlossaryIndex {
        let searchText = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard searchText.isEmpty == false else { return self }

        return GlossaryIndex(
            entries: entries.filter { $0.term.localizedStandardContains(searchText) }
        )
    }
}
