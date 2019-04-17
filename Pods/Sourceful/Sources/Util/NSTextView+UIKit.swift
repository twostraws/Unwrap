//
//  NSTextView+UIKit.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

#if os(macOS)

import AppKit

extension NSTextView {
	
	var text: String! {
		get {
			return string
		}
		set {
			self.string = newValue
		}
	}
	
	var tintColor: Color {
		set {
			insertionPointColor = newValue
		}
		get {
			return insertionPointColor
		}
	}
	
}

#endif