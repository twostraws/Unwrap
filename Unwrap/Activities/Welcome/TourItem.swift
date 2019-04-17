//
//  TourItem.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Stores a single page of the app tour loaded from JSON.
struct TourItem: Decodable {
    let image: String
    let title: String
    let text: String
}
