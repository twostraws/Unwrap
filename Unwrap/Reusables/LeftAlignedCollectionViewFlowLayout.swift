//
//  LeftAlignedCollectionViewFlowLayout.swift
//  TapToCode
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A custom collection view layout that aligns everything to the left, which looks better when working with Tap to Code.
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Get the general flow layout.
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        // Store the X position of the current element, starting with our left edge.
        var xPosition = sectionInset.left

        // Store the Y offset of those last row we positioned, starting offscreen.
        var yPosition: CGFloat = -1.0

        // In case we set some minimum interitem spacing elsewhere, grab it now.
        let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout
        let spacing = delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: 0) ?? minimumInteritemSpacing

        // Transform the standard flow layout attributes so they start from the left.
        return attributes.map { attribute in
            // If this item is lower than our previous item, go back to the start of the line.
            if attribute.frame.origin.y >= yPosition {
                xPosition = sectionInset.left
            }

            // Take a copy of the existing attribute so that UIKit doesn't complain about bad caches.
            // swiftlint:disable:next force_cast
            let attributeCopy = attribute.copy() as! UICollectionViewLayoutAttributes

            // Make this cell start at our current left position.
            attributeCopy.frame.origin.x = xPosition

            // Add its width plus any spacing to our current X position.
            xPosition += attribute.frame.width + spacing

            // And move our Y position down as needed.
            yPosition = max(attribute.frame.maxY, yPosition)

            return attributeCopy
        }
    }
}
