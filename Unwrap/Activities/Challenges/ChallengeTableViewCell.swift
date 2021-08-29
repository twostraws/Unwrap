//
//  TakeChallengeTableViewCell.swift
//  Unwrap
//
//  Created by Julian Schiavo on 27/4/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class ChallengeTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        textLabel?.text = NSLocalizedString("Start", comment: "")
        textLabel?.font = .preferredFont(forTextStyle: .title1)

        detailTextLabel?.text = NSLocalizedString("Each daily challenge may be attempted only once.", comment: "")
        detailTextLabel?.font = Unwrap.scaledBaseFont
        detailTextLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
