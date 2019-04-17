//
//  StatusTableViewCell.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    @IBOutlet var statusView: StatusView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // By setting accessibility element to false, we allow voiceover to access the elements inside
        isAccessibilityElement = false
    }
}
