/*
 The MIT License (MIT)

 Copyright (c) 2015 Max Konovalov

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

@objc(MKRingProgressViewStyle)
public enum RingProgressViewStyle: Int {
    case round
    case square
}

@IBDesignable
@objc(MKRingProgressView)
open class RingProgressView: UIView {
    /// The start color of the progress ring.
    @IBInspectable open var startColor: UIColor {
        get {
            return UIColor(cgColor: ringProgressLayer.startColor)
        }
        set {
            ringProgressLayer.startColor = newValue.cgColor
        }
    }

    /// The end color of the progress ring.
    @IBInspectable open var endColor: UIColor {
        get {
            return UIColor(cgColor: ringProgressLayer.endColor)
        }
        set {
            ringProgressLayer.endColor = newValue.cgColor
        }
    }

    /// The color of backdrop circle, visible at progress values between 0.0 and 1.0.
    /// If not specified, `startColor` with 15% opacity will be used.
    @IBInspectable open var backgroundRingColor: UIColor? {
        get {
            if let color = ringProgressLayer.backgroundRingColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            ringProgressLayer.backgroundRingColor = newValue?.cgColor
        }
    }

    /// The width of the progress ring. Defaults to `20`.
    @IBInspectable open var ringWidth: CGFloat {
        get {
            return ringProgressLayer.ringWidth
        }
        set {
            ringProgressLayer.ringWidth = newValue
        }
    }

    /// The style of the progress line end. Defaults to `round`.
    @objc open var style: RingProgressViewStyle {
        get {
            return ringProgressLayer.progressStyle
        }
        set {
            ringProgressLayer.progressStyle = newValue
        }
    }

    /// The opacity of the shadow below progress line end. Defaults to `1.0`.
    /// Values outside the [0,1] range will be clamped.
    @IBInspectable open var shadowOpacity: CGFloat {
        get {
            return ringProgressLayer.endShadowOpacity
        }
        set {
            ringProgressLayer.endShadowOpacity = newValue
        }
    }

    /// Whether or not to hide the progress ring when progress is zero. Defaults to `false`.
    @IBInspectable open var hidesRingForZeroProgress: Bool {
        get {
            return ringProgressLayer.hidesRingForZeroProgress
        }
        set {
            ringProgressLayer.hidesRingForZeroProgress = newValue
        }
    }

    /// The Antialiasing switch. Defaults to `true`.
    @IBInspectable open var allowsAntialiasing: Bool {
        get {
            return ringProgressLayer.allowsAntialiasing
        }
        set {
            ringProgressLayer.allowsAntialiasing = newValue
        }
    }

    /// The scale of the generated gradient image.
    /// Use lower values for better performance and higher values for more precise gradients.
    @IBInspectable open var gradientImageScale: CGFloat {
        get {
            return ringProgressLayer.gradientImageScale
        }
        set {
            ringProgressLayer.gradientImageScale = newValue
        }
    }

    /// The progress. Can be any nonnegative number, every whole number corresponding to one full revolution, i.e. 1.0 -> 360°, 2.0 -> 720°, etc. Defaults to `0.0`. Animatable.
    @IBInspectable open var progress: Double {
        get {
            return Double(ringProgressLayer.progress)
        }
        set {
            ringProgressLayer.progress = CGFloat(newValue)
        }
    }

    open override class var layerClass: AnyClass {
        return RingProgressLayer.self
    }

    private var ringProgressLayer: RingProgressLayer {
        return layer as! RingProgressLayer
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    private func setup() {
        layer.drawsAsynchronously = true
        layer.contentsScale = UIScreen.main.scale
        isAccessibilityElement = true
        #if swift(>=4.2)
        accessibilityTraits = UIAccessibilityTraits.updatesFrequently
        #else
        accessibilityTraits = UIAccessibilityTraitUpdatesFrequently
        #endif
        accessibilityLabel = "Ring progress"
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        ringProgressLayer.disableProgressAnimation = true
    }

    // MARK: Accessibility

    private var overriddenAccessibilityValue: String?

    open override var accessibilityValue: String? {
        get {
            if let override = overriddenAccessibilityValue {
                return override
            }
            return String(format: "%.f%%", progress * 100)
        }
        set {
            overriddenAccessibilityValue = newValue
        }
    }
}
