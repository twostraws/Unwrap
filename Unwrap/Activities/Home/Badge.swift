//
//  Badge.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// One badge the user can earn.
struct Badge: Decodable, Hashable, Identifiable {
    /// The user-facing name for this badge.
    let name: String

    /// The user-facing description for this badge.
    let description: String

    /// A named color that specifies how this badge's icon should be tinted.
    let color: String

    /// The SF Symbol drawn inside this badge's ring.
    let symbolName: String

    /// These two specify how this badge should be unlocked.
    let criterion: String
    let value: String

    var id: String { name }
}
