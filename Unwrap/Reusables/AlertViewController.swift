//
//  AlertViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

/// We have two types of alert: postscript is used specifically for postscript text after chapters, and hint is used for everything else.
enum AlertType {
    case postscript
    case hint
}

/// A re-usable alert view controller that shows a message and an OK button, and optionally also an alternate button.
class AlertViewController: UIViewController, Storyboarded {
    var coordinator: AlertHandling?

    @IBOutlet var icon: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var alternateButton: UIButton!

    /// A constraint that we can activate or deactivate depending on whether the alternate button is used or not.
    @IBOutlet var okToAlternate: NSLayoutConstraint!

    /// The main message inside the alert
    var body: NSAttributedString?

    /// Stores the type of alert this is. When the alert is dismissed we send this back to whatever coordinator is waiting for a notification.
    var alertType = AlertType.hint

    /// This view controller shows an OK button by default, but we can optionally add an alternate action and title if we want a second option.
    var alternateAction: (() -> Void)?
    var alternateTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // THE LINE BELOW IS ADDED AS A WARNING NOT TO DO THIS. This view controller may or may not have a coordinator depending on the desired behavior, so please do *not* try to add something like the below.
        // assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        /* HACK TO WORK AROUND UIIMAGEVIEW IGNORING TEMPLATE IMAGE TINT COLOR */
        /* See: https://openradar.appspot.com/18448072 */
        let image = icon.image
        icon.image = nil
        icon.image = image
        /* END HACK */

        let titleSize = UIFontMetrics(forTextStyle: .headline).scaledValue(for: 26)
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleSize)

        titleLabel.text = title
        bodyLabel.attributedText = body

        // If we have an alternate title then use it, otherwise hide the alternate action and deactivate the constraint that spaces it to the OK button,
        if let alternate = alternateTitle {
            alternateButton.setTitle(alternate, for: .normal)
        } else {
            alternateButton.isHidden = true
            okToAlternate.isActive = false
        }
    }

    /// Called when the alternate button is tapped. This dismisses the alert then runs our alternate action.
    @IBAction func alternateTapped(_ sender: Any) {
        // dismiss the alert immediately
        continueTapped(sender)

        // then run whatever the alternate action was
        alternateAction?()
    }

    /// Called when the OK button was tapped. If we have a coordinator let it decide what should happen; if not, just dismiss the alert.
    @IBAction func continueTapped(_ sender: Any) {
        if let coordinator = coordinator {
            coordinator.alertDismissed(type: alertType)
        } else {
            // we don't have a coordinator – just dismiss
            SwiftEntryKit.dismiss()
        }
    }
}
