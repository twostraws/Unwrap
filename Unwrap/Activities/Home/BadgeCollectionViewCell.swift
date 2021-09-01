//
//  BadgeCollectionViewCell.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One cell inside the badges collection view.
class BadgeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!

    var badge: Badge? {
        didSet {
            guard let badge = badge else {
                return
            }

            imageView.image = badge.image
            isAccessibilityElement = true
            accessibilityLabel = "Badge" + badge.name

            /// Highlight earned badges in whatever color was specified in the JSON. Also configures the accessibility values.
            if User.current.isBadgeEarned(badge) {
                imageView.tintColor = UIColor(bundleName: badge.color)
                accessibilityTraits = .button
                accessibilityValue = "Earned"
                accessibilityHint = "Share Badge"
            } else {
                imageView.tintColor = UIColor(bundleName: "Locked")
                accessibilityTraits = .none
                accessibilityValue = User.current.badgeProgress(badge).string
            }
        }
    }
}
