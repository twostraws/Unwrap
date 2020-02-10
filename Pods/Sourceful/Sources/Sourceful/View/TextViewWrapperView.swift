//
//  TextViewWrapperView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

#if os(macOS)
	
	class TextViewWrapperView: View {
		
		override func hitTest(_ point: NSPoint) -> NSView? {
			// Disable interaction, so we're not blocking the text view.
			return nil
		}
		
		override func layout() {
			super.layout()
			
			self.setNeedsDisplay(self.bounds)
		}
		
		override func resize(withOldSuperviewSize oldSize: NSSize) {
			super.resize(withOldSuperviewSize: oldSize)
			
			self.textView?.invalidateCachedParagraphs()

			self.setNeedsDisplay(self.bounds)
			
		}
		
		var textView: InnerTextView?
		
		override public func draw(_ rect: CGRect) {
			
			guard let textView = textView else {
				return
			}
			
			guard let theme = textView.theme else {
				super.draw(rect)
				textView.hideGutter()
				return
			}
			
			if theme.lineNumbersStyle == nil {

				textView.hideGutter()
				
				let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
				let path = BezierPath(rect: gutterRect)
				path.fill()
				
			} else {
			
				let contentHeight = textView.enclosingScrollView!.documentView!.bounds.height
			
				let yOffset = self.bounds.height - contentHeight
			
				var paragraphs: [Paragraph]
			
				if let cached = textView.cachedParagraphs {
					
					paragraphs = cached
					
				} else {
					
					paragraphs = generateParagraphs(for: textView, flipRects: true)
					textView.cachedParagraphs = paragraphs
					
				}
			
				paragraphs = offsetParagraphs(paragraphs, for: textView, yOffset: yOffset)
			
				let components = textView.text.components(separatedBy: .newlines)
			
				let count = components.count
			
				let maxNumberOfDigits = "\(count)".count
			
				textView.updateGutterWidth(for: maxNumberOfDigits)
			
				theme.gutterStyle.backgroundColor.setFill()
			
				let gutterRect = CGRect(x: 0, y: 0, width: textView.gutterWidth, height: rect.height)
				let path = BezierPath(rect: gutterRect)
				path.fill()
			
				drawLineNumbers(paragraphs, in: rect, for: textView)
			
			}
			
		}
		
	}
	
#endif
