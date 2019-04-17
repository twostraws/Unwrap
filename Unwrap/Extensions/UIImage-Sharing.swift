//
//  UIImage-Sharing.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIImage {
    /// Renders an image down to 256x256 on a white background, so it's good to share online.
    var imageForSharing: UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(bounds: drawRect)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(drawRect)

            draw(in: drawRect.insetBy(dx: 16, dy: 16))
        }
    }
}
