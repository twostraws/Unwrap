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

internal final class GradientGenerator {

    var scale: CGFloat = UIScreen.main.scale {
        didSet {
            if scale != oldValue {
                reset()
            }
        }
    }

    var size: CGSize = .zero {
        didSet {
            if size != oldValue {
                reset()
            }
        }
    }

    var colors: [CGColor] = [] {
        didSet {
            if colors != oldValue {
                reset()
            }
        }
    }

    var locations: [Float] = [] {
        didSet {
            if locations != oldValue {
                reset()
            }
        }
    }

    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            if startPoint != oldValue {
                reset()
            }
        }
    }

    var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            if endPoint != oldValue {
                reset()
            }
        }
    }

    private var generatedImage: CGImage?

    func reset() {
        generatedImage = nil
    }

    func image() -> CGImage {
        if let image = generatedImage {
            return image
        }

        let w = Int(size.width * scale)
        let h = Int(size.height * scale)
        let bitsPerComponent: Int = MemoryLayout<UInt8>.size * 8
        let bytesPerPixel: Int = bitsPerComponent * 4 / 8

        var data = [ARGB]()

        for y in 0..<h {
            for x in 0..<w {
                let c = pixelDataForGradient(at: CGPoint(x: x, y: y),
                                             size: CGSize(width: w, height: h),
                                             colors: colors,
                                             locations: locations,
                                             startPoint: startPoint,
                                             endPoint: endPoint)
                data.append(c)
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: bitsPerComponent, bytesPerRow: w * bytesPerPixel, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        ctx.interpolationQuality = .none
        ctx.setShouldAntialias(false)
        let img = ctx.makeImage()!
        generatedImage = img
        return img
    }

    private func pixelDataForGradient(at point: CGPoint,
                                      size: CGSize,
                                      colors: [CGColor],
                                      locations: [Float],
                                      startPoint: CGPoint,
                                      endPoint: CGPoint) -> ARGB {
        let t = conicalGradientStop(point, size, startPoint, endPoint)
        return interpolatedColor(t, colors, locations)
    }

    private func conicalGradientStop(_ point: CGPoint, _ size: CGSize, _ g0: CGPoint, _ g1: CGPoint) -> Float {
        let c = CGPoint(x: size.width * g0.x, y: size.height * g0.y)
        let s = CGPoint(x: size.width * (g1.x - g0.x), y: size.height * (g1.y - g0.y))
        let q = atan2(s.y, s.x)
        let p = CGPoint(x: point.x - c.x, y: point.y - c.y)
        var a = atan2(p.y, p.x) - q
        if a < 0 {
            a += 2 * .pi
        }
        let t = a / (2 * .pi)
        return Float(t)
    }

    private func interpolatedColor(_ t: Float, _ colors: [CGColor], _ locations: [Float]) -> ARGB {
        assert(!colors.isEmpty)
        assert(colors.count == locations.count)

        var p0: Float = 0
        var p1: Float = 1

        var c0 = colors.first!
        var c1 = colors.last!

        for (i, v) in locations.enumerated() {
            if v > p0 && t >= v {
                p0 = v
                c0 = colors[i]
            }
            if v < p1 && t <= v {
                p1 = v
                c1 = colors[i]
            }
        }

        let p: Float
        if p0 == p1 {
            p = 0
        } else {
            p = lerp(t, inRange: p0...p1, outRange: 0...1)
        }

        let color0 = ARGB(c0)
        let color1 = ARGB(c1)

        return color0.interpolateTo(color1, p)
    }

}

// MARK: - Color Data

fileprivate struct ARGB {
    let a: UInt8 = 0xff
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension ARGB: Equatable {
    static func ==(lhs: ARGB, rhs: ARGB) -> Bool {
        return (lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b)
    }
}

extension ARGB {

    init(_ color: CGColor) {
        let c = color.components?.map { min(max($0, 0.0), 1.0) }
        switch color.numberOfComponents {
        case 2:
            self.init(r: UInt8((c?[0])! * 0xff), g: UInt8((c?[0])! * 0xff), b: UInt8((c?[0])! * 0xff))
        case 4:
            self.init(r: UInt8((c?[0])! * 0xff), g: UInt8((c?[1])! * 0xff), b: UInt8((c?[2])! * 0xff))
        default:
            self.init(r: 0, g: 0, b: 0)
        }
    }

    func interpolateTo(_ color: ARGB, _ t: Float) -> ARGB {
        let r = lerp(t, self.r, color.r)
        let g = lerp(t, self.g, color.g)
        let b = lerp(t, self.b, color.b)
        return ARGB(r: r, g: g, b: b)
    }

}

// MARK: - Utility

fileprivate func lerp(_ t: Float, _ a: UInt8, _ b: UInt8) -> UInt8 {
    return UInt8(Float(a) + min(max(t, 0), 1) * (Float(b) - Float(a)))
}

fileprivate func lerp(_ value: Float, inRange: ClosedRange<Float>, outRange: ClosedRange<Float>) -> Float {
    return (value - inRange.lowerBound) * (outRange.upperBound - outRange.lowerBound) / (inRange.upperBound - inRange.lowerBound) + outRange.lowerBound
}
