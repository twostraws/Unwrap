//
//  UIView-EditingToolbar.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIView {
    /// Creates a UIView containing toolbars with common Swift syntax characters. Should be attached to any text entry fields where users can type code.
    static func editingToolbar(target: Any?, action: Selector?) -> EditingToolbarView {
        // We want two rows of characters
        let rows = [
            "[]{}()<>:.",
            "=+-*!?,/$"
        ]

        // Wrap our toolbars into into a single UIView that we can return.
        let wrapperView = EditingToolbarView(frame: CGRect(x: 0, y: 0, width: 320, height: rows.count * 44))
        wrapperView.translatesAutoresizingMaskIntoConstraints = false

        var toolbars = [String: Any]()
        var constraints = [String]()

        // Choose a (fixed!) but chunky font for the buttons.
        let buttonAttributes = [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .medium)]

        for (index, row) in rows.enumerated() {
            let toolbar = UIToolbar()
            toolbar.translatesAutoresizingMaskIntoConstraints = false

            // We insert spacers around each button so that the whole thing scales up neatly on larger displays.
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            var buttons = [spacer]

            // Loop over each character for this row and turn it into a button.
            for char in row {
                let stringChar = String(char)
                let button = UIBarButtonItem(title: stringChar, style: .plain, target: target, action: action)
                button.tag = numericCast(UInt8(ascii: stringChar.unicodeScalars[stringChar.startIndex]))
                button.setTitleTextAttributes(buttonAttributes, for: .normal)
                button.setTitleTextAttributes(buttonAttributes, for: .highlighted)
                buttons.append(button)
                buttons.append(spacer)
            }

            // Assign all buttons to the toolbar and make it size itself appropriately.
            toolbar.items = buttons
            toolbar.sizeToFit()
            wrapperView.addSubview(toolbar)

            // Force the leading and trailing edges to match our view so that toolbars run edge to edge.
            NSLayoutConstraint.activate([
                toolbar.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor)
            ])

            // Store this toolbar and its height so we can create constraints after the loop.
            toolbars["toolbar\(index)"] = toolbar
            constraints.append("[toolbar\(index)(==44)]")
        }

        wrapperView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(constraints.joined())|", options: [], metrics: nil, views: toolbars))

        return wrapperView
    }
}
