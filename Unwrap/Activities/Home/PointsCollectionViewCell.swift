//
//  PointsCollectionViewCell.swift
//  PointsCollectionViewCell
//
//  Created by Erik Drobne on 26/08/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation
import UIKit

class PointsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var textLabel: UILabel!

    var points: Int = 0 {
        didSet {
            textLabel.attributedText = NSAttributedString.makeTitle("Points", subtitle: points.formatted)
            accessibilityLabel = "\(points) points"
        }
    }
}
