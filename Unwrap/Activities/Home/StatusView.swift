//
//  StatusView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import MKRingProgressView
import UIKit

class StatusView: UIImageView, UserTracking {
    /// The start color of the activity ring.
    var strokeColorStart = UIColor.black

    /// The end color of the activity ring; works best when different to startColor because we intend to shoot past 100%.
    var strokeColorEnd = UIColor.black

    /// How thick the activity ring should be drawn.
    var lineWidth: CGFloat = 10

    /// Whether there should be a shadow at the end of the activity ring; looks best when set to 1 when shooting past 100%.
    var shadowOpacity: CGFloat = 0

    /// This draws the ring around the outside. We can't use a simple CAShapeLayer because it doesn't allow us to overshoot 100%.
    private let ringProgressView = RingProgressView()

    /// This draws the user's rank inside the ring.
    private var imageView: UIImageView!

    /// When set to true, the rank image is drawn as a template image so it can be recolored.
    var useTemplateImages = false

    // Sometimes we need to animate beyond 100%, for example if need 50 points to get to the next level and we just earned 200. These three facilitate that: we track our previous rank fraction before awarding points, and if the new rank fraction is below the old one and we've been asked to animate beyond the end, then we do so.
    //
    // NOTE: The home screen does not animate past the end, whereas the awards screen does.
    var currentRankFraction: Double = User.smallestRankFraction
    var currentTotalPoints = 0
    var animatePastEnd = false

    /// Performs some one-time set up of child views, then positions the views appropriately.
    override func layoutSubviews() {
        super.layoutSubviews()

        if imageView == nil {
            registerForUserChanges()

            ringProgressView.translatesAutoresizingMaskIntoConstraints = false
            ringProgressView.startColor = strokeColorStart
            ringProgressView.endColor = strokeColorEnd
            ringProgressView.backgroundRingColor = UIColor(bundleName: "StatusViewRingBackground")
            ringProgressView.ringWidth = lineWidth
            ringProgressView.shadowOpacity = shadowOpacity
            addSubview(ringProgressView)

            imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            addSubview(imageView)

            NSLayoutConstraint.activate([
                ringProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                ringProgressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                ringProgressView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
                ringProgressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),

                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
            ])
        }

        userDataChanged()

        // Always force the stroke end to its absolute starting point regardless of what userDataChanged() is trying to do. This allows us to start on 0 and count up to maximum with animation.
        ringProgressView.progress = User.current.rankFraction
    }

    /// Redraw both the activity ring and rank image when the user data changed. This can occur statically (redraw on the homescreen when points are awarded) or dynamically (redraw on the awards screen while the user is watching.)
    func userDataChanged() {
        if useTemplateImages {
            imageView.image = User.current.rankImage.withRenderingMode(.alwaysTemplate)
        } else {
            imageView.image = User.current.rankImage
        }

        UIView.animate(withDuration: 2) {
            if self.animatePastEnd == true && User.current.rankFraction < self.currentRankFraction {
                // if we're configured to run past the end and we *have* run past the end then add 1 to the rank fraction so that we *do* run past the end
                self.ringProgressView.progress = User.current.rankFraction + 1
            } else if self.animatePastEnd == true && User.current.rankFraction == self.currentRankFraction &&
                self.currentTotalPoints < User.current.totalPoints {
                // if we're configured to run past the end, have gained points, but our overall rank fraction stayed the same, this means we've gone up precisely one level so we need to animate it as such
                self.ringProgressView.progress = 1.0
            } else {
                // otherwise, just use the regular rank fraction
                self.ringProgressView.progress = User.current.rankFraction
            }
        }

        currentRankFraction = User.current.rankFraction
        currentTotalPoints = User.current.totalPoints
    }
}
