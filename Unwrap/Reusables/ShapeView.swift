//
//  ShapeView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A custom UIView subclass that renders a normalized UIBezierPath.
class ShapeView: UIView {
    /// How thick the path should be drawn.
    @IBInspectable var strokeWidth: CGFloat = 2.0

    /// The color used to draw the stroke.
    @IBInspectable var strokeColor: UIColor = UIColor.black

    /// The color used to fill the path.
    var fillColor: UIColor = UIColor.clear

    /// The path to draw.
    var path: UIBezierPath?

    /// Request a CAShapeLayer as our backing layer.
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    /// When it's time to layout our subviews, use this chance to scale up our path and place it in the shape layer. Paths should be normalized, meaning that they span the width and height 0 to 1. We then multiply that by our available space to make sure the path scales up neatly.
    override func layoutSubviews() {
        guard let layer = self.layer as? CAShapeLayer else { return }

        // Figure out how much bigger we need to make our path in order for it to fill the available space without clipping.
        let multiplier = min(bounds.width, bounds.height)

        // Take a copy of our current path so that we can transform it using our multiplier.
        guard let pathCopy = path?.copy() as? UIBezierPath else { return }
        pathCopy.apply(CGAffineTransform(scaleX: multiplier, y: multiplier))

        // Configure the CAShapeLayer using all our settings.
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = strokeWidth
        layer.path = pathCopy.cgPath
    }

    /// Makes the shape view draw itself by animating the strokeEnd property of the underlying shape layer.
    func draw(delay: CFTimeInterval, duration: CFTimeInterval) {
        guard let layer = self.layer as? CAShapeLayer else { return }

        layer.strokeEnd = 0

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .backwards
        layer.add(animation, forKey: "line")

        layer.strokeEnd = 1
    }

    /// Makes the shape view draw itself by animating the strokeEnd property of the underlying shape layer. This variant uses keyframes, allowing for more precise control over the draw animation.
    func draw(delay: CFTimeInterval, duration: Double, keyFrameValues values: [NSNumber]) {
        guard let layer = self.layer as? CAShapeLayer else { return }

        layer.strokeEnd = 0

        let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.values = values
        animation.keyTimes = values
        animation.duration = duration
        animation.timingFunctions = (1...values.count).map { _ in CAMediaTimingFunction(name: .easeInEaseOut) }

        animation.fillMode = .backwards
        layer.add(animation, forKey: "line")

        layer.strokeEnd = 1
    }
}
