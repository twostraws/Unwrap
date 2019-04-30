//
//  GlossaryTableViewCell.swift
//  Unwrap
//
//  Created by Julian Schiavo on 26/4/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class GlossaryTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        textLabel?.font = Unwrap.scaledBoldFont
        detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
        detailTextLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
