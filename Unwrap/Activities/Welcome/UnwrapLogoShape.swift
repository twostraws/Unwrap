//
//  UnwrapLogoShape.swift
//  Unwrap
//

import SwiftUI

struct UnwrapLogoShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }

        var path = Path()
        path.move(to: point(0.534, 0.5816))
        path.addCurve(
            to: point(0.1877, 0.088),
            control1: point(0.534, 0.5816),
            control2: point(0.2529, 0.4205)
        )
        path.addCurve(
            to: point(0.9728, 0.8259),
            control1: point(0.4922, 0.4949),
            control2: point(1.0968, 0.4148)
        )
        path.addCurve(
            to: point(0.0397, 0.5431),
            control1: point(0.7118, 0.5248),
            control2: point(0.3329, 0.7442)
        )
        path.addCurve(
            to: point(0.6211, 0.0279),
            control1: point(0.508, 1.1956),
            control2: point(1.3042, 0.5345)
        )
        path.addCurve(
            to: point(0.6904, 0.3615),
            control1: point(0.7282, 0.2481),
            control2: point(0.6904, 0.3615)
        )
        return path
    }
}
