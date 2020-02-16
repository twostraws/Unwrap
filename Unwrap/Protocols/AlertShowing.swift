//
//  AlertShowing.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Allows conforming types to show alerts, optionally with a coordinator and an alternate action configuration.
protocol AlertShowing { }

extension AlertShowing {
    /// This shows an alert message. Note: this a default implementation of showAlert() in the AlertShowing protocol, but it isn't declared in the protocol because we don't want conforming types to provide their own implementation.
    func showAlert(title: String = "Hint", body: String, coordinator: AlertHandling? = nil, alternateTitle: String? = nil, alternateAction: (() -> Void)? = nil) {
        showAlert(title: title, body: body.fromSimpleHTML(), coordinator: coordinator, alternateTitle: alternateTitle, alternateAction: alternateAction)
    }

    func showAlert(title: String = "Hint", body: NSAttributedString, coordinator: AlertHandling? = nil, alternateTitle: String? = nil, alternateAction: (() -> Void)? = nil) {
        let alert = AlertViewController.instantiate()

        alert.title = title
        alert.body = body
        alert.alternateTitle = alternateTitle
        alert.alternateAction = alternateAction
        alert.coordinator = coordinator

        alert.presentAsAlert()
    }
}
