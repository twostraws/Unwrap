//
//  UIViewController-Alerts.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

extension UIViewController: AlertShowing {
    /// Does all the leg work of making any UIViewController be shown inside a pre-styled SwiftEntryKit alert.
    func presentAsAlert() {
        var attributes = EKAttributes()
        attributes.displayDuration = .infinity

        let widthConstraint: EKAttributes.PositionConstraints.Edge

        // If we're on phone we want the alert to take up 90% of the view width, but for everything else a fixed width is fine.
        if UIDevice.current.userInterfaceIdiom == .phone {
            widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        } else {
            widthConstraint = EKAttributes.PositionConstraints.Edge.constant(value: 400)
        }

        let heightConstraint = EKAttributes.PositionConstraints.Edge.intrinsic
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: UIColor(bundleName: "AlertBackgroundDim"))
        attributes.position = EKAttributes.Position.center
        view.clipsToBounds = true
        view.layer.cornerRadius = 20

        SwiftEntryKit.display(entry: self, using: attributes)
    }

    /// Shows an alert only if it hasn't already been shown.
    func showFirstTimeAlert(name: String, title: String, message: String) {
        let defaultsName = "Shown\(name)"

        if UserDefaults.standard.bool(forKey: defaultsName) == false {
            showAlert(title: title, body: message)
            UserDefaults.standard.set(true, forKey: defaultsName)
        }
    }
}
