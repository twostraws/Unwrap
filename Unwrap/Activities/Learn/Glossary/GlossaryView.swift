//
//  GlossaryView.swift
//  Unwrap
//

import SwiftUI

struct GlossaryView: View {
    @State private var searchText = ""

    let index: GlossaryIndex

    var body: some View {
        let filteredIndex = index.filtered(by: searchText)

        List {
            ForEach(filteredIndex.sections) { section in
                Section(section.title) {
                    ForEach(section.entries) { entry in
                        GlossaryEntryView(entry: entry, searchText: searchText)
                    }
                }
                .sectionIndexLabel(section.title)
            }
        }
        .overlay(alignment: .top) {
            if filteredIndex.entries.isEmpty {
                Text("No Results")
                    .bold()
                    .padding(.top, 30)
            }
        }
        .navigationTitle("Glossary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search"
        )
    }
}
