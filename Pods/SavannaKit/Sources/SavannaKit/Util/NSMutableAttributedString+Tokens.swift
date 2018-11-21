//
//  NSMutableAttributedString+Tokens.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 02/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

public extension NSMutableAttributedString {
	
	convenience public init(source: String, tokens: [Token], theme: SyntaxColorTheme) {
		
		self.init(string: source)
		
		var attributes = [NSAttributedString.Key: Any]()
		
		let spaceAttrString = NSAttributedString(string: " ", attributes: [.font: theme.font])
		let spaceWidth = spaceAttrString.size().width
		
		let themeInfo = ThemeInfo(theme: theme, spaceWidth: spaceWidth)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.paragraphSpacing = 2.0
		paragraphStyle.defaultTabInterval = themeInfo.spaceWidth * 4
		paragraphStyle.tabStops = []
		
		// Improve performance by manually specifying writing direction.
		paragraphStyle.baseWritingDirection = .leftToRight
		paragraphStyle.alignment = .left
		
		let wholeRange = NSRange(location: 0, length: source.count)
		
		attributes[.paragraphStyle] = paragraphStyle

		for (attr, value) in theme.globalAttributes() {
			attributes[attr] = value
		}

		self.setAttributes(attributes, range: wholeRange)
		
		for token in tokens {
			
			if token.isPlain {
				continue
			}
			
			let tokenRange = token.range
			
			let range = source.nsRange(fromRange: tokenRange)
			
			if token.isEditorPlaceholder {
				
				let startRange = NSRange(location: range.lowerBound, length: 2)
				let endRange = NSRange(location: range.upperBound - 2, length: 2)
				
				let contentRange = NSRange(location: range.lowerBound + 2, length: range.length - 4)
				
				var attr = [NSAttributedString.Key: Any]()
				
				attr[.editorPlaceholder] = EditorPlaceholderState.inactive
				
				self.addAttributes(theme.attributes(for: token), range: contentRange)
				
				self.addAttributes([.foregroundColor: Color.clear, .font: Font.systemFont(ofSize: 0.01)], range: startRange)
				self.addAttributes([.foregroundColor: Color.clear, .font: Font.systemFont(ofSize: 0.01)], range: endRange)
				
				self.addAttributes(attr, range: range)
				continue
			}
			
			self.setAttributes(theme.attributes(for: token), range: range)
			
		}
		
	}
	
}
