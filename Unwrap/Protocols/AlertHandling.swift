//
//  AlertHandling.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

/// Declares that a conforming type is able to handle alerts being dismissed.
protocol AlertHandling {
    func alertDismissed(type: AlertType)
}
