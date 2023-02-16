//
//  BackgroundSupplementaryView.swift
//  BackgroundSupplementaryView
//
//  Created by Erik Drobne on 31/08/2021.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation
import UIKit

class BackgroundSupplementaryView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
