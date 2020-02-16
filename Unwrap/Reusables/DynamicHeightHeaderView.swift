//
//  DynamicHeightHeaderView.swift
//  Unwrap
//
//  Created by Marco Contino on 5/16/19.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

/// A replacement for the built-in section headers in UITableView, adding support for multi-line text. By default our text doesn't wrap over lines, but if the user increases their font size using Dynamic Type then this class ensures header titles go over multiple lines correctly.
class DynamicHeightHeaderView: UITableViewHeaderFooterView {

    /// The label that is shown inside our header view
    let headerLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Create the dynamic section header label, activates its constraints, and sets its attributes.
    private func configureHeader() {
        contentView.addSubview(headerLabel)
        contentView.backgroundColor = UIColor(bundleName: "BackgroundLight")
        headerLabel.backgroundColor = UIColor(bundleName: "BackgroundLight")
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.font = Unwrap.scaledBoldFont
        headerLabel.numberOfLines = 0
        headerLabel.accessibilityTraits.insert(.header)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
}
