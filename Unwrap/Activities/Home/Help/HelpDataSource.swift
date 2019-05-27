//
//  HelpDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Help table view, handing taps back to a delegate where appropriate.
class HelpDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var coordinator: HomeCoordinator?
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as? DynamicHeightHeaderView {
            headerView.headerLabel.text = items[section].title
            return headerView
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? HelpTableViewCell else {
            fatalError("Failed to dequeue a HelpTableViewCell.")
        }

        let item = items[indexPath.section]

        // Wrap our help text in HTML so we catch links correctly.
        let contents = String.wrapperHTML(allowTheming: true, width: 320, slimLayout: true).replacingOccurrences(of: "[BODY]", with: item.text)
        let data = Data(contents.utf8)
        let str = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        cell.textView.attributedText = str
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selected = item(at: indexPath.section)

        switch selected.action {
        case "showTour":
            coordinator?.showTour()

        default:
            break
        }
    }
}
