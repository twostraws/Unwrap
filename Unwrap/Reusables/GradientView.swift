//
//  GradientView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A UIView subclass that draws linear gradients. This really ought to be @IBDesignable, but it makes IB crash a lot, so…
class GradientView: UIView {
    /// The color at the start of the gradient.
    @IBInspectable var firstColor: UIColor = UIColor.white

    /// The color at the end of the gradient.
    @IBInspectable var secondColor: UIColor = UIColor.black

    /// Requests that we get CAGradientLayer backing for this view.
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    /// When it's time to lay things out, set up our gradient layer using the specified colors.
    override func layoutSubviews() {
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
    }
}
