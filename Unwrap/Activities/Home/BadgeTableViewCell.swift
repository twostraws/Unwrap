//
//  BadgeTableViewCell.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
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

        // By setting accessibility element to false, we allow voiceover to access the elements inside
        isAccessibilityElement = false
    }
    func userDataChanged() {
        collectionView.reloadData()
    }

    /// This is a dubious hack, but it's the best I can do right now. When the badges collection view is created, it likes to be made at the same size as the storyboard, and so the cells inside the collection will have only five columns or so – even when run on an iPad where there is much more space. This forces the collection view to reload when it's shown, which in turn makes it correctly take up all space.
    ///
    /// To make this work even as weakly as it doesn right now, we need to specify a precise height for the cell, force it to do its layout immediately, then reload its data when it's shown. To avoid problems around rotation, we can reload every time it comes into view.
    ///
    /// Downsides: this makes a massive badge area on large devices like the 12.9-inch iPad Pro, most of which is empty, and of course means it's reloading its data unnecessarily. Upsides: you can actually see all the badges on all devices. So… win?
    func applyLayoutWorkaround() {
        collectionView.reloadData()
    }
}
