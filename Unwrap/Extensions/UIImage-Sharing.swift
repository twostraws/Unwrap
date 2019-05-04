//
//  UIImage-Sharing.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIImage {
    // Creates a UIImage containing a gradient of a specific size and color.
    static func gradient(at size: CGSize, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors.map { $0.cgColor }

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }

    /// Renders an image down to a branded picture, so it's good to share online.
    var imageForSharing: UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: 512, height: 512)
        let gradient = UIImage.gradient(at: drawRect.size, colors: [UIColor(bundleName: "UnwrapGradientTop"), UIColor(bundleName: "UnwrapGradientBottom")])

        let renderer = UIGraphicsImageRenderer(bounds: drawRect)

        return renderer.image { ctx in
            gradient.draw(in: drawRect)

            UIColor.white.set()
            let desiredSize: CGFloat = 256
            let scaleFactor = desiredSize / max(size.width, size.height)

            let height = size.height * scaleFactor
            let width = size.width * scaleFactor

            let x = 256 - (width / 2)
            let y = 180 - (height / 2)

            draw(in: CGRect(x: x, y: y, width: width, height: height))

            guard let pathCopy = UIBezierPath.logo.copy() as? UIBezierPath else { return }
            pathCopy.apply(CGAffineTransform(scaleX: 128, y: 128))
            ctx.cgContext.translateBy(x: 256 - 64, y: drawRect.height - 160)
            ctx.cgContext.addPath(pathCopy.cgPath)
            ctx.cgContext.setLineWidth(2)
            UIColor.white.set()
            ctx.cgContext.strokePath()
        }
    }
}
