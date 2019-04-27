//
//  NewsTableViewCell.swift
//  Unwrap
//
//  Created by Michael Charland on 2019-04-02.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

/// Represents a row in the News table view that contains an article to read.
class NewsTableViewCell: UITableViewCell {
    // custom connections for the image view, title, and subtitle
    private let customImageView = UIImageView()
    private let customTextLabel = UILabel()
    private let customDetailTextLabel = UILabel()

    /// The dot beside the image indicating if the article has been read or not.
    let readNotification = UILabel()

    // Use our custom image view in place of the default image view
    override var imageView: UIImageView? {
        return customImageView
    }

    // Use our custom text label in place of the default text label
    override var textLabel: UILabel? {
        return customTextLabel
    }

    // Use our custom detail text label in place of the default detail text label
    override var detailTextLabel: UILabel? {
        return customDetailTextLabel
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        setupReadNotification()
        setupImageView()
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupReadNotification() {
        readNotification.text = "•"
        readNotification.font = .systemFont(ofSize: 36)
        readNotification.textColor = UIColor(bundleName: "Primary")
        readNotification.translatesAutoresizingMaskIntoConstraints = false

        readNotification.setContentHuggingPriority(.required, for: .horizontal)
        readNotification.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(readNotification)

        NSLayoutConstraint.activate([
            readNotification.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            readNotification.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -2)
        ])
    }

    func setupImageView() {
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customImageView)

        customImageView.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        customImageView.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)

        let topAnchor = customImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 5)
        topAnchor.priority = UILayoutPriority(999)

        let bottomAnchor = customImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        bottomAnchor.priority = UILayoutPriority(999)

        let constraints = [
            customImageView.widthAnchor.constraint(equalToConstant: 84),
            customImageView.heightAnchor.constraint(equalToConstant: 56),
            topAnchor,
            bottomAnchor,
            customImageView.leadingAnchor.constraint(equalTo: readNotification.trailingAnchor, constant: 5),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupLabels() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        customTextLabel.font = Unwrap.scaledBoldFont
        customTextLabel.numberOfLines = 0
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(customTextLabel)

        customTextLabel.setContentHuggingPriority(.required, for: .vertical)
        customTextLabel.setContentHuggingPriority(.required, for: .horizontal)
        customTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let textLabelConstraints = [
            customTextLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            customTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            customTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
        ]

        customDetailTextLabel.font = .preferredFont(forTextStyle: .caption1)
        customDetailTextLabel.numberOfLines = 0
        customDetailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(customDetailTextLabel)

        customDetailTextLabel.setContentHuggingPriority(.required, for: .vertical)
        customDetailTextLabel.setContentHuggingPriority(.required, for: .horizontal)
        customDetailTextLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)

        let detailTextLabelConstraints = [
            customDetailTextLabel.topAnchor.constraint(equalTo: customTextLabel.bottomAnchor, constant: 3),
            customDetailTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            customDetailTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            customDetailTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ]

        let containerViewConstraints = [
            containerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ]

        NSLayoutConstraint.activate(textLabelConstraints + detailTextLabelConstraints + containerViewConstraints)
    }
}
