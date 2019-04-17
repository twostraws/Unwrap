//
//  Replacement.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Stores one replacement while generating Spot the Error activities. For example, we might look for FUNCTION_NAME and replace it calculateWages, generateBill, forecastRevenue, and so on.
struct Replacement: Decodable {
    /// The name of the thing to search for, e.g. FUNCTION_NAME.
    let name: String

    /// An array of possible replacements that can be selected from randomly.
    let values: [String]
}
