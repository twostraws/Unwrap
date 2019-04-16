//
//  NSRegularExpression-HardCoded.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension NSRegularExpression {
    /// A convenience initializer that lets us create regular expressions without constantly force unwrapping.
    convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            fatalError("Illegal regex: \(pattern)")
        }
    }
}
