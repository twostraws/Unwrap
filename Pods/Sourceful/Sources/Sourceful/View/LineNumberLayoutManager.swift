//
//  LineNumberLayoutManager.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 04/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//
// Currently unused in SavannaKit, but might be a better way of drawing the line numbers.
// Converted from https://github.com/alldritt/TextKit_LineNumbers

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

class LineNumberLayoutManager: NSLayoutManager {
	
	var lastParaLocation = 0
	var lastParaNumber = 0
	
	func _paraNumber(for charRange: NSRange) -> Int {
		//  NSString does not provide a means of efficiently determining the paragraph number of a range of text.  This code
		//  attempts to optimize what would normally be a series linear searches by keeping track of the last paragraph number
		//  found and uses that as the starting point for next paragraph number search.  This works (mostly) because we
		//  are generally asked for continguous increasing sequences of paragraph numbers.  Also, this code is called in the
		//  course of drawing a pagefull of text, and so even when moving back, the number of paragraphs to search for is
		//  relativly low, even in really long bodies of text.
		//
		//  This all falls down when the user edits the text, and can potentially invalidate the cached paragraph number which
		//  causes a (potentially lengthy) search from the beginning of the string.
		if charRange.location == lastParaLocation {
			return lastParaNumber
		} else if charRange.location < lastParaLocation {
			//  We need to look backwards from the last known paragraph for the new paragraph range.  This generally happens
			//  when the text in the UITextView scrolls downward, revaling paragraphs before/above the ones previously drawn.
			let s = textStorage?.string
			var paraNumber: Int = lastParaNumber
			(s as NSString?)?.enumerateSubstrings(in: NSRange(location: Int(charRange.location), length: Int(lastParaLocation - charRange.location)), options: [.byParagraphs, .substringNotRequired, .reverse], using: {(_ substring: String?, _ substringRange: NSRange, _ enclosingRange: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void in
				if enclosingRange.location <= charRange.location {
					stop?.pointee = true
				}
				paraNumber -= 1
			})
			lastParaLocation = charRange.location
			lastParaNumber = paraNumber
			return paraNumber
		} else {
			//  We need to look forward from the last known paragraph for the new paragraph range.  This generally happens
			//  when the text in the UITextView scrolls upwards, revealing paragraphs that follow the ones previously drawn.
			let s = textStorage?.string
			var paraNumber: Int = lastParaNumber
			(s as NSString?)?.enumerateSubstrings(in: NSRange(location: lastParaLocation, length: Int(charRange.location - lastParaLocation)), options: [.byParagraphs, .substringNotRequired], using: {(_ substring: String?, _ substringRange: NSRange, _ enclosingRange: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void in
				if enclosingRange.location >= charRange.location {
					stop?.pointee = true
				}
				paraNumber += 1
			})
			lastParaLocation = charRange.location
			lastParaNumber = paraNumber
			return paraNumber
		}
	}

    #if os(macOS)
	override func processEditing(for textStorage: NSTextStorage, edited editMask: NSTextStorageEditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {
		super.processEditing(for: textStorage, edited: editMask, range: newCharRange, changeInLength: delta, invalidatedRange: invalidatedCharRange)
		if invalidatedCharRange.location < lastParaLocation {
			//  When the backing store is edited ahead the cached paragraph location, invalidate the cache and force a complete
			//  recalculation.  We cannot be much smarter than this because we don't know how many paragraphs have been deleted
			//  since the text has already been removed from the backing store.
			lastParaLocation = 0
			lastParaNumber = 0
		}
	}
    #else
    override func processEditing(for textStorage: NSTextStorage, edited editMask: NSTextStorage.EditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {
        super.processEditing(for: textStorage, edited: editMask, range: newCharRange, changeInLength: delta, invalidatedRange: invalidatedCharRange)
        if invalidatedCharRange.location < lastParaLocation {
            //  When the backing store is edited ahead the cached paragraph location, invalidate the cache and force a complete
            //  recalculation.  We cannot be much smarter than this because we don't know how many paragraphs have been deleted
            //  since the text has already been removed from the backing store.
            lastParaLocation = 0
            lastParaNumber = 0
        }
    }
    #endif
	
	var gutterWidth: CGFloat = 0.0
	
	override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
		super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
		
		//  Draw line numbers.  Note that the background for line number gutter is drawn by the LineNumberTextView class.
		
//		let style = DefaultTheme().lineNumbersStyle!
		
		let atts: [NSAttributedString.Key: Any] = [:
//			.font: style.font,
//			.foregroundColor : style.textColor
		]
		
		var gutterRect: CGRect = .zero
		var paraNumber: Int = 0
		
		enumerateLineFragments(forGlyphRange: glyphsToShow, using: {(_ rect: CGRect, _ usedRect: CGRect, _ textContainer: NSTextContainer?, _ glyphRange: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void in
			
			let charRange: NSRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
			let paraRange: NSRange? = (self.textStorage?.string as NSString?)?.paragraphRange(for: charRange)
			
			//   Only draw line numbers for the paragraph's first line fragment.  Subsiquent fragments are wrapped portions of the paragraph and don't get the line number.
			if charRange.location == paraRange?.location {
				gutterRect = CGRect(x: 0, y: rect.origin.y, width: self.gutterWidth, height: rect.size.height).offsetBy(dx: origin.x, dy: origin.y)
				paraNumber = self._paraNumber(for: charRange)
				let ln = "\(Int(UInt(paraNumber)) + 1)"
				let size: CGSize = ln.size(withAttributes: atts)
				ln.draw(in: gutterRect.offsetBy(dx: gutterRect.width - 4 - size.width, dy: 0), withAttributes: atts)
			}
		})
		
		//  Deal with the special case of an empty last line where enumerateLineFragmentsForGlyphRange has no line
		//  fragments to draw.
//		if NSMaxRange(glyphsToShow) > numberOfGlyphs {

		if self.textStorage!.string.isEmpty || self.textStorage!.string.hasSuffix("\n") {

			let ln = "\(Int(UInt(paraNumber)) + 2)"
			let size: CGSize = ln.size(withAttributes: atts)
			gutterRect = gutterRect.offsetBy(dx: 0.0, dy: gutterRect.height)
			ln.draw(in: gutterRect.offsetBy(dx: gutterRect.width - 4 - size.width, dy: 0), withAttributes: atts)
			
		}
		
		let rect = BezierPath(rect: CGRect(x: 0, y: 0, width: 200, height: 500))
		Color.red.withAlphaComponent(0.5).setFill()
		rect.fill()
	}

}
