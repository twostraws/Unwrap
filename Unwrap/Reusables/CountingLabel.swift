//
//  CountingLabel.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A UILabel subclass that can animate from one value to another.
class CountingLabel: UILabel {
    /// How fast we should animate changes.
    let preferredFramesPerSecond = 60

    var title = ""

    /// We attach our animation to a CADisplayLink for maximum efficiency.
    var displayLink: CADisplayLink?

    /// The number we're starting at.
    var fromValue = 0

    /// The number we are currently displaying.
    var currentValue = 0

    /// The number we want to animate to.
    var targetValue = 0

    /// How much to add our subtract at every step of the animation.
    var changeSpeed = 0

    func count(start: Int, end: Int) {
        // Attempt to make sure that we adjust the counting speed so that it happens in a roughly similar time.
        let delta = Double(abs(end - start))
        changeSpeed = Int(round(delta / Double(preferredFramesPerSecond)))

        // Configure our animation to happen using a CADisplayLink, so the work happens as soon as frame draw ends.
        displayLink = CADisplayLink(target: self, selector: #selector(updateCount))
        displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        displayLink?.add(to: RunLoop.current, forMode: .common)

        fromValue = start
        currentValue = start
        targetValue = end
    }

    /// Called every time a frame draw happens thanks to CADisplayLink, so its our chance to adjust our current value towards our target value, then update our label.
    @objc func updateCount() {
        if targetValue > fromValue {
            // We need to add numbers to reach our target.
            currentValue += changeSpeed

            if currentValue > targetValue {
                stopWorking()
            }
        } else {
            // We need to subtract numbers to reach our target.
            currentValue -= changeSpeed

            if currentValue < targetValue {
                stopWorking()
            }
        }

        // Redraw our label contents using the new currentValue.
        if title.isEmpty {
            text = String(currentValue)
        } else {
            attributedText = NSAttributedString.makeTitle(title, subtitle: currentValue.formatted)
        }
    }

    // Target reached; clamp it and stop doing more work.
    private func stopWorking() {
        currentValue = targetValue
        displayLink?.invalidate()
    }
}
