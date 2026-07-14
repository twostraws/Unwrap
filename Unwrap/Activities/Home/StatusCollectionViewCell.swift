//
//  StatusCollectionViewCell.swift
//  StatusCollectionViewCell
//
//  Created by Erik Drobne on 25/08/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import UIKit

class StatusCollectionViewCell: UICollectionViewCell {
    @IBOutlet var statusView: StatusView!

    nonisolated override func awakeFromNib() {
        MainActor.assumeIsolated {
            super.awakeFromNib()
            // By setting accessibility element to false, we allow voiceover to access the elements inside
            isAccessibilityElement = false

            statusView.shadowOpacity = 0
            statusView.strokeColorStart = UIColor(bundleName: "Rank-Start")
            statusView.strokeColorEnd = UIColor(bundleName: "Rank-End")
        }
    }
}
