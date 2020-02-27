//
//  GlossaryDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/01/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

/// Loads glossary entries from JSON and displays them grouped alphabetically.
class GlossaryDataSource: NSObject, UITableViewDataSource, UISearchResultsUpdating {
    weak var delegate: GlossaryViewController?

    /// Stores all glossary entries grouped by their first letter
    var sortedEntries = [String: [GlossaryEntry]]()

    /// Stores the alphabetical letters we want to show along the right edge
    var sectionTitles = [String]()

    /// Stores all entries from data file, used for filtering table view data during search
    var originalEntries = [GlossaryEntry]()

    /// Loads the glossary definitions from JSON and groups them alphabetically
    override init() {
        super.init()
        let entries = Bundle.main.decode([GlossaryEntry].self, from: "glossary.json")
        originalEntries = entries
        createSortedEntriesAndTitles(from: entries)
    }

    /// Creates the sortedEntries dictionary from a given array of GlossaryEntry and creates the section titles String array
    func createSortedEntriesAndTitles(from entries: [GlossaryEntry]) {
        sortedEntries = Dictionary(grouping: entries) { String($0.term.prefix(1)).uppercased() }
        sectionTitles = sortedEntries.keys.sorted()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        return sortedEntries[sectionTitle]?.count ?? 0
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let key = sectionTitles[indexPath.section]
        if let entries = sortedEntries[key] {
            let entry = entries[indexPath.row]
            cell.textLabel?.text = entry.term
            cell.detailTextLabel?.attributedText = entry.description.fromSimpleHTML()
        }

        return cell
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }

        if text.isEmpty {
            createSortedEntriesAndTitles(from: originalEntries)
        } else {
            let filteredEntries = originalEntries.filter { return $0.term.lowercased().contains(text) }
            createSortedEntriesAndTitles(from: filteredEntries)
        }

        delegate?.searchPerformed(noResults: sectionTitles.isEmpty)
    }
}
