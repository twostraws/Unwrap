//
//  BadgeDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The data source for the badges collection view. This loads the list of badges, then serves them up as individual cells.
class BadgeDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, AlertShowing {
    /// An array of all badges the user can earn.
    let badges = Bundle.main.decode([Badge].self, from: "Badges.json")

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Badge", for: indexPath) as? BadgeCollectionViewCell else {
            fatalError("Failed to dequeue BadgeCollectionViewCell.")
        }

        let badge = badges[indexPath.item]
        cell.imageView.image = badge.image
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "Badge" + badge.name

        /// Highlight earned badges in whatever color was specified in the JSON. Also configures the accessibility values.
        if User.current.isBadgeEarned(badge) {
            cell.imageView.tintColor = UIColor(bundleName: badge.color)
            cell.accessibilityTraits = .button
            cell.accessibilityValue = "Earned"
            cell.accessibilityHint = "Share Badge"
        } else {
            cell.imageView.tintColor = UIColor(bundleName: "Locked")
            cell.accessibilityTraits = .none
            cell.accessibilityValue = User.current.badgeProgress(badge).string
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = badges[indexPath.item]

        /// Do not perform any action when voice over enabled and Badge is not earned. The accessibilityValue already tells the current progress.
        if UIAccessibility.isVoiceOverRunning && !User.current.isBadgeEarned(badge) { return }

        guard let coordinator = collectionView.findCoordinator() as? HomeCoordinator else { return }

        coordinator.shareBadge(badge)
    }
}
