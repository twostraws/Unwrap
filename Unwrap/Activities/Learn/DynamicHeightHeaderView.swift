//
//  DynamicHeightHeaderView.swift
//  Unwrap
//
//  Created by Marco Contino on 5/16/19.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class DynamicHeightHeaderView: UITableViewHeaderFooterView {

    /** TableView section header */
    let headerLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHeader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Function to create the dynamic section header label by activating its constraints and setting its attributes.
    */
    private func configureHeader() {
        contentView.addSubview(headerLabel)
        contentView.backgroundColor = UIColor(bundleName: "BackgroundLight")
        headerLabel.backgroundColor = UIColor(bundleName: "BackgroundLight")
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.font = Unwrap.scaledBoldFont
        headerLabel.numberOfLines = 0
        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
}
