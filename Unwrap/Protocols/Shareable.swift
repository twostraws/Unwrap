//
//  Shareable.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 2/25/21.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation
import UIKit
protocol Shareable {
    var textToShare: Reader { set get }
    var navigationController: UINavigationController? {set get}
    func share() -> Void
}
