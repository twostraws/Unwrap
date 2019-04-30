//
//  PreviousChallengeTableViewCell.swift
//  Unwrap
//
//  Created by Julian Schiavo on 27/4/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class PreviousChallengeTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = Unwrap.scaledBaseFont
        detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
        detailTextLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
