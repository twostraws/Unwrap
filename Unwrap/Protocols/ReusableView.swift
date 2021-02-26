//
//  ReusableView.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 2/26/21.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation

protocol ReusableView {
    static var reuseString: String { get }
}

extension ReusableView {
    static var reuseString: String {
        return String(describing: self)
    }
}


