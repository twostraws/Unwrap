//
//  Chapter.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One chapter of Swift in Sixty Seconds.
struct Chapter: Decodable {
    var name: String
    var sections: [String]

    lazy var bundleNameSections: [String] = {
        sections.map { $0.bundleName }
    }()
}
