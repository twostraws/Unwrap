//
//  SourceCodeTheme.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import SavannaKit

public protocol SourceCodeTheme: SyntaxColorTheme {
	
	func color(for syntaxColorType: SourceCodeTokenType) -> Color
	
}

extension SourceCodeTheme {
	
	public func globalAttributes() -> [NSAttributedStringKey: Any] {
		
		var attributes = [NSAttributedStringKey: Any]()
		
		attributes[.font] = font
		attributes[.foregroundColor] = Color.white
		
		return attributes
	}
	
	public func attributes(for token: SavannaKit.Token) -> [NSAttributedStringKey: Any] {
		var attributes = [NSAttributedStringKey: Any]()
		
		if let token = token as? SimpleSourceCodeToken {
			attributes[.foregroundColor] = color(for: token.type)
		}
		
		return attributes
	}
	
}
