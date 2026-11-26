//
//  ProgressRing.swift
//  Unwrap
//

import SwiftUI

/// An activity ring that fades from one color to another, and can run past 100% by overlapping its own start.
///
/// The ring is drawn as a single gradient arc that never quite closes. Once progress reaches the point where the arc
/// would touch its own tail, the whole arc rotates instead of growing, and a solid arc in the start color fills the
/// space it leaves behind. That keeps the end color and its shadow on the leading edge however far around we go.
struct ProgressRing: View, Animatable {
    /// How much of the ring to fill. Values above 1 produce additional revolutions.
    var progress: Double

    /// The color at the tail of the ring.
    var startColor: Color

    /// The color at the leading edge of the ring.
    var endColor: Color

    /// The color of the unfilled ring.
    var trackColor: Color

    /// How thick the ring should be drawn.
    var lineWidth: CGFloat = 10

    /// Whether the leading edge casts a shadow onto the ring ahead of it; looks best when running past 100%.
    var showsEndShadow = false

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let side = min(size.width, size.height)
        let width = min(lineWidth, side / 2)
        let radius = (side - width) / 2
        guard radius > 0 else { return }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let stroke = StrokeStyle(lineWidth: width, lineCap: .round)
        let top = -Double.pi / 2

        // The gradient arc stops short of a full circle, leaving room for both of its round caps plus a small gap
        // where the gradient can wrap from the end color back to the start color without being seen.
        let capAngle = 1.1 * atan(width / 2 / radius)
        let maximumSweep = (2 * Double.pi) - (3 * capAngle)
        let sweep = 2 * Double.pi * max(progress, 0)
        let arcSweep = min(sweep, maximumSweep)
        let rotation = sweep - arcSweep
        let headAngle = top + sweep

        func arc(from start: Double, to end: Double) -> Path {
            Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(start),
                    endAngle: .radians(end),
                    clockwise: false
                )
            }
        }

        let ring = arc(from: 0, to: 2 * Double.pi)
        context.stroke(ring, with: .color(trackColor), lineWidth: width)

        // Fill in behind the gradient arc once it has started rotating away from the top.
        if rotation > 0 {
            let tail = arc(from: top, to: top + min(rotation, 2 * Double.pi))
            context.stroke(tail, with: .color(startColor), style: stroke)
        }

        // The leading edge, which is also what casts the shadow. Clipping to the ring stops the shadow spilling
        // onto whatever is behind us, and nudging it forwards makes it fall on the part we're about to cover.
        let head = CGPoint(
            x: center.x + (radius * cos(headAngle)),
            y: center.y + (radius * sin(headAngle))
        )
        let headPath = Path(ellipseIn: CGRect(
            x: head.x - (width / 2),
            y: head.y - (width / 2),
            width: width,
            height: width
        ))

        context.drawLayer { layer in
            if showsEndShadow {
                layer.clip(to: ring.strokedPath(StrokeStyle(lineWidth: width)))
                layer.addFilter(
                    .shadow(
                        color: .black.opacity(0.6),
                        radius: width / 4,
                        x: width / 10 * cos(headAngle + (Double.pi / 2)),
                        y: width / 10 * sin(headAngle + (Double.pi / 2))
                    )
                )
            }

            layer.fill(headPath, with: .color(startColor))
        }

        guard sweep > 0 else { return }

        // Hold each color steady for a short distance either side of the wrap, so that both round caps are
        // one solid color rather than catching the edge of the fade.
        let solid = 1.5 * width / (2 * Double.pi * radius)
        let gradient = Gradient(stops: [
            .init(color: startColor, location: 0),
            .init(color: startColor, location: solid),
            .init(color: endColor, location: 1 - solid),
            .init(color: endColor, location: 1)
        ])

        let arcStart = top + rotation
        let shading = GraphicsContext.Shading.conicGradient(
            gradient,
            center: center,
            angle: .radians(arcStart - (1.5 * capAngle))
        )

        context.stroke(arc(from: arcStart, to: arcStart + arcSweep), with: shading, style: stroke)
    }
}
