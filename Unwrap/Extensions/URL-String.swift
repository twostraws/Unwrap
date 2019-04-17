//
//  URL-String.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension URL {
    /// A simple initializer that creates URLs that are hard-coded.
    init(staticString: String) {
        self.init(string: staticString)!
    }
}
