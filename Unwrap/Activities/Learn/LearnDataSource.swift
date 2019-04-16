//
//  LearnDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Learn table view.
class LearnDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: LearnViewController?

    func title(for indexPath: IndexPath) -> String {
        return Unwrap.chapters[indexPath.section].sections[indexPath.row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Unwrap.chapters.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Unwrap.chapters[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Unwrap.chapters[section].sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let chapter = Unwrap.chapters[indexPath.section]
        let section = chapter.sections[indexPath.row]
        cell.textLabel?.text = section

        // Decide how to show the checkmark for this section.
        let score = User.current.ratingForSection(section.bundleName)

        if score == 0 {
            // Always show a check image, but make it invisible
            // for uncompleted sections – this helps keep text
            // alignment uniform across the table.
            cell.imageView?.image = UIImage(bundleName: "Check")
            cell.imageView?.alpha = 0
        } else if score == 100 {
            // They read this chapter but didn't review it.
            cell.imageView?.image = UIImage(bundleName: "Check")
            cell.imageView?.tintColor = UIColor(bundleName: "CoursePartial")
            cell.imageView?.alpha = 1
        } else if score == 200 {
            // They read and reviewed this chapter.
            cell.imageView?.image = UIImage(bundleName: "Check")
            cell.imageView?.tintColor = UIColor(bundleName: "CourseFull")
            cell.imageView?.alpha = 1
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChapter = Unwrap.chapters[indexPath.section]
        let selectedSection = selectedChapter.sections[indexPath.row]
        delegate?.startStudying(title: selectedSection)
    }
}
