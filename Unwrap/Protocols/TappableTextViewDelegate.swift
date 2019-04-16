//
//  TappableTextViewDelegate.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A protocol that lets a conforming type respond to links being tapped in a TappableTextView.
protocol TappableTextViewDelegate: AnyObject {
    func linkTapped(_ url: URL)
}
