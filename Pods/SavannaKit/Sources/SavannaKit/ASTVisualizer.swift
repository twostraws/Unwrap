//
//  ASTVisualizer.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 26/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

// TODO: make this protocol oriented, without depending on Lioness.
/*

fileprivate let minNodeHeight: CGFloat = 40.0
fileprivate let minNodeWidth: CGFloat = 40.0

fileprivate let minNodeXSpacing: CGFloat = 20.0
fileprivate let minNodeYSpacing: CGFloat = 50.0

fileprivate let fontSize: CGFloat = 14.0

fileprivate extension NSAttributedString {

	convenience init(withNodeDescription nodeDescription: String) {

		let style = NSMutableParagraphStyle()
		style.alignment = .center

		let attributes: [NSAttributedStringKey: Any] = [
			.font: NSFont.systemFont(ofSize: fontSize),
			.paragraphStyle: style
		]

		self.init(string: nodeDescription, attributes: attributes)

	}

}

fileprivate extension ASTNodeDescriptor {

	/// Includes children, and spacing
	var drawSize: CGSize {

		return CGSize(width: drawWidth, height: drawHeight)
	}

	/// Includes children
	var drawWidth: CGFloat {

		let spacing = minNodeXSpacing * CGFloat(widestNumberOfChildNodes)

		let width = nodeTreeDrawSize.width + spacing

		return width
	}

	/// Includes children
	var drawHeight: CGFloat {

		let totalNumberOfNodesDeep = CGFloat(deephestNumberOfChildNodes) + 1
		let spacing = minNodeYSpacing * (totalNumberOfNodesDeep + 1)

		let height = totalNumberOfNodesDeep * minNodeHeight + spacing

		return height
	}

	var drawSizeForDirectChildren: CGSize {

		var width: CGFloat = 0.0
		var height: CGFloat = 0.0

		for c in descriptionChildNodes {

			width += c.node.nodeSize.width
			height += c.node.nodeSize.height

		}

		return CGSize(width: width, height: height)

	}

	/// Single node size
	var nodeSize: CGSize {

		if let text = nodeDescription {

			let attr = NSAttributedString(withNodeDescription: text)

			let size = attr.size()
			let width = max(minNodeWidth, size.width + 20)
			let height = max(minNodeHeight, size.height + 10)

			return CGSize(width: width, height: height)
		}

		return CGSize(width: minNodeWidth, height: minNodeHeight)
	}

	// make lazy?
	var deephestNumberOfChildNodes: Int {

		if descriptionChildNodes.isEmpty {
			return 0
		}

		var deephest = 1

		for childNode in descriptionChildNodes {

			let d = 1 + childNode.node.deephestNumberOfChildNodes

			if d > deephest {
				deephest = d
			}

		}

		return deephest

	}

	// make lazy?
	var widestNumberOfChildNodes: Int {

		if descriptionChildNodes.isEmpty {
			return 1
		}

		var wide = 0

		for childNode in descriptionChildNodes {

			wide += childNode.node.widestNumberOfChildNodes

		}

		return wide

	}

	// make lazy?
	/// Without spacing
	var nodeTreeDrawSize: CGSize {

		if descriptionChildNodes.isEmpty {
			return self.nodeSize
		}

		var s = CGSize.zero

		for childNode in descriptionChildNodes {

			s = s + childNode.node.nodeTreeDrawSize

		}

		return s

	}

}

fileprivate func +(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public class ASTVisualizer {

	fileprivate let body: BodyNode

	public init(body: BodyNode) {

		self.body = body

	}

	lazy fileprivate var canvasSize: CGSize = {

		return self.body.drawSize

	}()

	public func draw() -> NSImage? {

		let size = canvasSize

		return draw(withSize: size)

	}

	fileprivate func draw(withSize size: CGSize) -> NSImage {

		let composedImage = NSImage(size: size)

		composedImage.lockFocus()
		let ctx = NSGraphicsContext.current
		ctx?.imageInterpolation = .high
		ctx?.shouldAntialias = true

		let rect1 = CGRect(origin: .zero, size: size)

		let path = NSBezierPath(rect: normalizedRect(rect1))

		NSColor.white.setFill()
		path.fill()

		let startX = size.width/2.0
		let startPoint = CGPoint(x: startX, y: minNodeYSpacing)

		drawNode(body, atPosition: startPoint)

		composedImage.unlockFocus()

		return composedImage
	}

	fileprivate func normalizedRect(_ r: CGRect) -> CGRect {

		// invert y for macOS
		let invertedY = canvasSize.height - (r.origin.y + r.height)
		return CGRect(x: r.origin.x, y: invertedY, width: r.width, height: r.height)
	}

	fileprivate func normalizedPoint(_ r: CGPoint) -> CGPoint {

		// invert y for macOS
		let invertedY = canvasSize.height - (r.y)
		return CGPoint(x: r.x, y: invertedY)
	}

	fileprivate func drawNode(_ node: ASTNodeDescriptor, atPosition point: CGPoint, withParentRect parentRect: CGRect? = nil, conditionalConnection: Bool = false) {

		let x: CGFloat = point.x - node.nodeSize.width/2.0
		let y: CGFloat = point.y

		let rect = CGRect(x: x, y: y, width: node.nodeSize.width, height: node.nodeSize.height)

		let path = NSBezierPath(roundedRect: normalizedRect(rect), xRadius: 12.0, yRadius: 12.0)

		NSColor.blue.withAlphaComponent(0.2).setFill()

		path.fill()

		NSColor.blue.withAlphaComponent(0.6).setStroke()
		path.lineWidth = 2.0
		path.stroke()

		if let parentRect = parentRect {

			let linePath = NSBezierPath()
			let pointA = CGPoint(x: parentRect.origin.x + parentRect.size.width / 2.0, y: parentRect.origin.y + parentRect.size.height)
			linePath.move(to: normalizedPoint(pointA))

			let pointB = CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y)

			linePath.line(to: normalizedPoint(pointB))

			if conditionalConnection {
				linePath.setLineDash([4.0], count: 1, phase: 2.0)
			}

			NSColor.blue.withAlphaComponent(0.6).setStroke()
			linePath.lineWidth = 2.0
			linePath.stroke()
		}

		if let text = node.nodeDescription {

			let attr = NSAttributedString(withNodeDescription: text)

			let size = attr.size()

			var textRect = rect

			// TODO: max 0?
			textRect.origin.y += (rect.height - size.height) / 2.0

			attr.draw(in: normalizedRect(textRect))

		}

		var i: CGFloat = 0

		for childNode in node.descriptionChildNodes {

			let farX = point.x - node.drawSize.width / 2.0

			var newXPosition = farX

			for j in 0..<Int(i+1) {

				let jWidth = node.descriptionChildNodes[j].node.drawSize.width
				if CGFloat(j) == i {
					newXPosition += jWidth / 2.0
				} else {
					newXPosition += jWidth
				}

			}

			let newYPosition = point.y + minNodeHeight + minNodeYSpacing

			let childPosition = CGPoint(x: newXPosition, y: newYPosition)

			drawNode(childNode.node, atPosition: childPosition, withParentRect: rect, conditionalConnection: childNode.isConnectionConditional)

			i += 1
		}

	}

}
*/
