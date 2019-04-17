//
//  KeyboardAvoidingScrollView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIScrollView {
    /// Makes any scrolling view (table views, text views, scroll views) able to adjust its scroll set up when the keyboard is shown or hidden.
    func avoidKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    /// Called when the keyboard is shown, hidden, or adjusted (e.g. the QuickType keyboard is shown or hidden), so we recalculate the scrolling layout for this control.
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardScreenEndFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // we somehow failed to get the keyboard size? Yay!
            return
        }

        let keyboardViewEndFrame = convert(keyboardScreenEndFrame, from: nil)
        let safeAreaFrame = safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -contentInset.bottom)
        let intersection = safeAreaFrame.intersection(keyboardViewEndFrame)
        contentInset.bottom = intersection.height
        scrollIndicatorInsets = contentInset
        layoutIfNeeded()

        scrollToBottom(animated: true)
    }

    /// Forces this view to get down to the bottom because we just moved what "bottom" means.
    func scrollToBottom(animated: Bool) {
        if contentSize.height < bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - (bounds.size.height - contentInset.bottom))
        setContentOffset(bottomOffset, animated: animated)
    }
}
