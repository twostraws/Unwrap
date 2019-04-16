//
//  BadgesView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A simple wrapper view that automatically sizes itself to fit the complete collection view inside it
class BadgesView: UIView {
    var collectionView: UICollectionView!

    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: UIView.noIntrinsicMetric, height: collectionView.collectionViewLayout.collectionViewContentSize.height)
        return size
    }
}
