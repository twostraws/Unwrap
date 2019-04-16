//
//  HelpDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Help table view, handing taps back to a delegate where appropriate.
class HelpDataSource: NSObject, UITableViewDataSource {
    weak var delegate: TappableTextViewDelegate?
    let items = Bundle.main.decode([HelpItem].self, from: "Help.json")

    func item(at index: Int) -> HelpItem {
        return items[index]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? HelpTableViewCell else {
            fatalError("Failed to dequeue a HelpTableViewCell.")
        }

        let item = items[indexPath.section]

        // add a couple of line breaks at the end to provide clearer section spacing
        cell.textView.text = "\(item.text)\n\n"
        cell.textView.linkDelegate = delegate

        if item.action.isEmpty {
            cell.selectionStyle = .none
            cell.textView.isUserInteractionEnabled = true
            cell.textView.textColor = nil
        } else {
            cell.selectionStyle = .default
            cell.textView.isUserInteractionEnabled = false
            cell.textView.textColor = UIColor(bundleName: "Primary")
        }

        return cell
    }
}
