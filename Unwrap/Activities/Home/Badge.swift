//
//  Badge.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One badge the user can earn.
struct Badge: Decodable {
    /// The user-facing name for this badge.
    var name: String

    /// The user-facing description for this badge.
    var description: String

    /// A named color that specifies how this badge's icon should be tinted.
    var color: String

    /// These two specify how this badge should be unlocked.
    var criterion: String
    var value: String

    /// This converts the badge's name into its icon name
    var filename: String {
        let cleanBadgeName = name.replacingOccurrences(of: "[\\?',]", with: "", options: .regularExpression)
        return cleanBadgeName.replacingOccurrences(of: " ", with: "-")
    }

    /// The image for this badge.
    var image: UIImage {
        return UIImage(bundleName: "Badge-\(filename)")
    }
}
