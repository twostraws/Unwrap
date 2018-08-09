//
//  BadgeTableViewCell.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import UIKit

/// This table view cell holds a collection view wrapped up inside a regular view so we can get good cell autosizing. Its job is to watch for user changes and refresh the collection view as needed.
class BadgeTableViewCell: UITableViewCell, UserTracking {
    @IBOutlet var badgesView: BadgesView!
    @IBOutlet var collectionView: UICollectionView!

    override func awakeFromNib() {
        badgesView.collectionView = collectionView

        // although our main table view will get reloaded when user data changes, iOS will reuse this existing cell if it has one and so we must reload it ourselves as needed.
        registerForUserChanges()
    }

    func userDataChanged() {
        collectionView.reloadData()
    }
}
