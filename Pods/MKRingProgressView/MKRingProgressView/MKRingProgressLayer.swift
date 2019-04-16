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

@objc(MKRingProgressLayer)
open class RingProgressLayer: CALayer {
    /// The progress ring start color.
    @objc open var startColor: CGColor = UIColor.red.cgColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The progress ring end color.
    @objc open var endColor: CGColor = UIColor.blue.cgColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The color of the background ring.
    @objc open var backgroundRingColor: CGColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The width of the progress ring.
    @objc open var ringWidth: CGFloat = 20 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The style of the progress line end (rounded or straight).
    @objc open var progressStyle: RingProgressViewStyle = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The opacity of the shadow under the progress end.
    @objc open var endShadowOpacity: CGFloat = 1.0 {
        didSet {
            endShadowOpacity = min(max(endShadowOpacity, 0.0), 1.0)
            setNeedsDisplay()
        }
    }
    
    /// Whether or not to hide the progress ring when progress is zero.
    @objc open var hidesRingForZeroProgress: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Whether or not to allow anti-aliasing for the generated image.
    @objc open var allowsAntialiasing: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The scale of the generated gradient image.
    /// Use lower values for better performance and higher values for more precise gradients.
    @objc open var gradientImageScale: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The current progress shown by the view.
    /// Values less than 0.0 are clamped. Values greater than 1.0 present multiple revolutions of the progress ring.
    @NSManaged public var progress: CGFloat
    
    /// Disable actions for `progress` property.
    internal var disableProgressAnimation: Bool = false
    
    private let gradientGenerator = GradientGenerator()
    
    open override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    open override func action(forKey event: String) -> CAAction? {
        if !disableProgressAnimation, event == "progress" {
            if let action = super.action(forKey: "opacity") as? CABasicAnimation {
                let animation = action.copy() as! CABasicAnimation
                animation.keyPath = event
                animation.fromValue = presentation()?.value(forKey: event)
                animation.toValue = nil
                return animation
            } else {
                let animation = CABasicAnimation(keyPath: event)
                animation.duration = 0.001
                return animation
            }
        }
        return super.action(forKey: event)
    }
    
    open override func display() {
        contents = contentImage()
    }
    
    func contentImage() -> CGImage? {
        let size = bounds.size
        if #available(iOS 10.0, tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat.default()
            let image = UIGraphicsImageRenderer(size: size, format: format).image { ctx in
                drawContent(in: ctx.cgContext)
            }
            return image.cgImage
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                return nil
            }
            drawContent(in: ctx)
            let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    private func drawContent(in context: CGContext) {
        context.setShouldAntialias(allowsAntialiasing)
        context.setAllowsAntialiasing(allowsAntialiasing)
        
        let useGradient = startColor != endColor
        
        let squareSize = min(bounds.width, bounds.height)
        let squareRect = CGRect(x: (bounds.width - squareSize) / 2, y: (bounds.height - squareSize) / 2,
                                width: squareSize, height: squareSize)
        let gradientRect = squareRect.integral
        
        let w = min(ringWidth, squareSize / 2)
        let r = min(bounds.width, bounds.height) / 2 - w / 2
        let c = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let p = max(0.0, disableProgressAnimation ? progress : presentation()?.progress ?? 0.0)
        let angleOffset = CGFloat.pi / 2
        let angle = 2 * .pi * p - angleOffset
        let minAngle = 1.1 * atan(0.5 * w / r)
        let maxAngle = 2 * .pi - 3 * minAngle - angleOffset
        
        let circleRect = squareRect.insetBy(dx: w / 2, dy: w / 2)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        let angle1 = angle > maxAngle ? maxAngle : angle
        
        context.setLineWidth(w)
        context.setLineCap(progressStyle.lineCap)
        
        // Draw backdrop circle
        
        context.addPath(circlePath.cgPath)
        let bgColor = backgroundRingColor ?? startColor.copy(alpha: 0.15)!
        context.setStrokeColor(bgColor)
        context.strokePath()
        
        // Draw solid arc
        
        if angle > maxAngle {
            let offset = angle - maxAngle
            
            let arc2Path = UIBezierPath(arcCenter: c,
                                        radius: r,
                                        startAngle: -angleOffset,
                                        endAngle: offset,
                                        clockwise: true)
            context.addPath(arc2Path.cgPath)
            context.setStrokeColor(startColor)
            context.strokePath()
            
            context.translateBy(x: circleRect.midX, y: circleRect.midY)
            context.rotate(by: offset)
            context.translateBy(x: -circleRect.midX, y: -circleRect.midY)
        }
        
        // Draw shadow and progress end
        
        if p > 0.0 || !hidesRingForZeroProgress {
            context.saveGState()
            
            if endShadowOpacity > 0.0 {
                context.addPath(CGPath(__byStroking: circlePath.cgPath,
                                       transform: nil,
                                       lineWidth: w,
                                       lineCap: .round,
                                       lineJoin: .round,
                                       miterLimit: 0)!)
                context.clip()
                
                let shadowOffset = CGSize(width: w / 10 * cos(angle + angleOffset),
                                          height: w / 10 * sin(angle + angleOffset))
                context.setShadow(offset: shadowOffset,
                                  blur: w / 3,
                                  color: UIColor(white: 0.0, alpha: endShadowOpacity).cgColor)
            }
            
            let arcEnd = CGPoint(x: c.x + r * cos(angle1), y: c.y + r * sin(angle1))
            
            let shadowPath: UIBezierPath = {
                switch progressStyle {
                case .round:
                    return UIBezierPath(ovalIn: CGRect(x: arcEnd.x - w / 2,
                                                       y: arcEnd.y - w / 2,
                                                       width: w,
                                                       height: w))
                case .square:
                    let path = UIBezierPath(rect: CGRect(x: arcEnd.x - w / 2,
                                                         y: arcEnd.y - 2,
                                                         width: w,
                                                         height: 2))
                    path.apply(CGAffineTransform(translationX: -arcEnd.x, y: -arcEnd.y))
                    path.apply(CGAffineTransform(rotationAngle: angle1))
                    path.apply(CGAffineTransform(translationX: arcEnd.x, y: arcEnd.y))
                    return path
                }
            }()
            
            let shadowFillColor: CGColor = {
                let fadeStartProgress: CGFloat = 0.02
                if !hidesRingForZeroProgress || p > fadeStartProgress {
                    return startColor
                }
                // gradually decrease shadow opacity
                return startColor.copy(alpha: p / fadeStartProgress)!
            }()
            context.addPath(shadowPath.cgPath)
            context.setFillColor(shadowFillColor)
            context.fillPath()
            
            context.restoreGState()
        }
        
        // Draw gradient arc
        
        let gradient: CGImage? = {
            guard useGradient else {
                return nil
            }
            let s = Float(1.5 * w / (2 * .pi * r))
            gradientGenerator.scale = gradientImageScale
            gradientGenerator.size = gradientRect.size
            gradientGenerator.colors = [endColor, endColor, startColor, startColor]
            gradientGenerator.locations = [0.0, s, 1.0 - s, 1.0]
            gradientGenerator.endPoint = CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0)
            return gradientGenerator.image()
        }()
        
        if p > 0.0 {
            let arc1Path = UIBezierPath(arcCenter: c,
                                        radius: r,
                                        startAngle: -angleOffset,
                                        endAngle: angle1,
                                        clockwise: true)
            if let gradient = gradient {
                context.saveGState()
                
                context.addPath(CGPath(__byStroking: arc1Path.cgPath,
                                       transform: nil,
                                       lineWidth: w,
                                       lineCap: progressStyle.lineCap,
                                       lineJoin: progressStyle.lineJoin,
                                       miterLimit: 0)!)
                context.clip()
                
                context.interpolationQuality = .none
                context.draw(gradient, in: gradientRect)
                
                context.restoreGState()
            } else {
                context.setStrokeColor(startColor)
                context.setLineWidth(w)
                context.setLineCap(progressStyle.lineCap)
                context.addPath(arc1Path.cgPath)
                context.strokePath()
            }
        }
    }
}

private extension RingProgressViewStyle {
    var lineCap: CGLineCap {
        switch self {
        case .round:
            return .round
        case .square:
            return .butt
        }
    }
    
    var lineJoin: CGLineJoin {
        switch self {
        case .round:
            return .round
        case .square:
            return .miter
        }
    }
}
