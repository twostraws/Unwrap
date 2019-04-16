//
//  SyntaxTextViewLayoutManager.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 09/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

public enum EditorPlaceholderState {
	case active
	case inactive
}

public extension NSAttributedString.Key {
	
	static let editorPlaceholder = NSAttributedString.Key("editorPlaceholder")

}

class SyntaxTextViewLayoutManager: NSLayoutManager {
	
	override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
		
		#if os(macOS)

			guard let context = NSGraphicsContext.current else {
				return
			}
			
		#else
		
			guard let context = UIGraphicsGetCurrentContext() else {
				return
			}
			
		#endif
		
		let range = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
		
		var placeholders = [(CGRect, EditorPlaceholderState)]()
		
		textStorage?.enumerateAttribute(.editorPlaceholder, in: range, options: [], using: { (value, range, stop) in
			
			if let state = value as? EditorPlaceholderState {
				
				// the color set above
				let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
				let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil)
				
				let rect = self.boundingRect(forGlyphRange: glyphRange, in: container ?? NSTextContainer())
				
				placeholders.append((rect, state))
				
			}
			
		})
		
		#if os(macOS)

			context.saveGraphicsState()
			context.cgContext.translateBy(x: origin.x, y: origin.y)
		
		#else
			
			context.saveGState()
			context.translateBy(x: origin.x, y: origin.y)
		
		#endif
		
		for (rect, state) in placeholders {
			
			// UIBezierPath with rounded
			
			let color: Color
			
			switch state {
			case .active:
				color = Color.white.withAlphaComponent(0.8)
			case .inactive:
				color = .darkGray
			}

			color.setFill()
			
			let radius: CGFloat = 4.0
			
			#if os(macOS)

				let path = BezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

			#else
				
				let path = BezierPath(roundedRect: rect, cornerRadius: radius)

			#endif
			
			path.fill()
			
		}
		
		#if os(macOS)

			context.restoreGraphicsState()

		#else

			context.restoreGState()

		#endif

		super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

	}
	
}
